{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    types
    elem
    concatStringsSep
    filterAttrs
    ;
  cfg = config.services.samba;
  primaryUser = config.users.primaryUser;
  # Share names flagged as Time Machine destinations and not blacklisted.
  tmShares = builtins.attrNames (
    filterAttrs (name: share: share.timeMachine && !(elem name cfg.disableShares)) cfg.directories
  );
in
{
  options.services.samba = {

    directories = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              path = mkOption {
                type = types.str;
                description = "Path to share";
              };
              browseable = mkOption {
                type = types.bool;
                default = true;
              };
              writable = mkOption {
                type = types.bool;
                default = true;
              };
              comment = mkOption {
                type = types.str;
                default = name;
              };
              guestOk = mkOption {
                type = types.bool;
                default = false;
                description = "Allow guest access without authentication";
              };
              timeMachine = mkOption {
                type = types.bool;
                default = false;
                description = ''
                  Advertise this share as a Time Machine destination.

                  Adds the fruit Time Machine support and an avahi _adisk._tcp
                  record, so macOS discovers it in System Settings without
                  needing `tmutil setdestination`.
                '';
              };

              sizeLimit = mkOption {
                type = types.nullOr types.str;
                default = null;
                example = "2T";
                description = ''
                  Cap for a Time Machine share, e.g. "2T". Time Machine expands
                  to fill whatever it is given, so an uncapped destination will
                  eventually consume the pool.
                '';
              };

              users = mkOption {
                type = types.listOf types.str;
                default = [ primaryUser ];
                description = "Users allowed to access this share";
              };
            };
          }
        )
      );
      default = { };
      description = "Samba shared directories. Mapped to services.samba.settings internally.";
    };

    macosCompat = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Load the fruit VFS module for macOS clients.

        Without it, Finder stores resource forks and metadata as separate
        AppleDouble files - the `._name` stubs that litter a share and, being
        real files, survive long after whatever they described. With it, that
        metadata goes into xattrs instead, and Finder behaves properly
        (correct rename semantics, no spurious dotfiles).

        Harmless for Linux and Windows clients; fruit only engages for macOS.
      '';
    };

    passwordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "config.sops.secrets.\"samba/mirza\".path";
      description = ''
        File containing the plaintext SMB password for the primary user.

        Samba cannot reuse the system login hash: SMB authenticates with NTLM
        challenge-response, so the server needs the NT hash (MD4 of the
        UTF-16LE password), while users.users.<name>.hashedPassword is a
        yescrypt/SHA-512 crypt hash. Neither is derivable from the other, so
        Samba keeps its own password database.

        When set, a oneshot unit seeds that database before smbd starts,
        making the share user declarative instead of a manual `smbpasswd -a`.
      '';
    };

    disableShares = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Share names to disable (blacklist)";
    };

  };

  config = mkIf cfg.enable {
    services = {
      samba = {
        openFirewall = mkDefault true;

        settings =
          let
            active = filterAttrs (name: _: !(elem name cfg.disableShares)) cfg.directories;
          in
          (builtins.mapAttrs (
            _: share:
            {
              inherit (share) path;
              browseable = if share.browseable then "yes" else "no";
              "read only" = if share.writable then "no" else "yes";
              "guest ok" = if share.guestOk then "yes" else "no";
              "valid users" = concatStringsSep " " share.users;
              "force user" = builtins.head share.users;
              inherit (share) comment;
            }
            // lib.optionalAttrs share.timeMachine {
              "fruit:time machine" = "yes";
            }
            // lib.optionalAttrs (share.timeMachine && share.sizeLimit != null) {
              "fruit:time machine max size" = share.sizeLimit;
            }
          ) active)
          // {
            global = {
              "server min protocol" = mkDefault "SMB2_10";
              "client min protocol" = mkDefault "SMB2_10";
              "map to guest" = mkDefault "Bad User";
            }
            // lib.optionalAttrs cfg.macosCompat {
              # Order matters: fruit must precede streams_xattr.
              "vfs objects" = mkDefault "catia fruit streams_xattr";
              "fruit:metadata" = mkDefault "stream";
              "fruit:model" = mkDefault "MacSamba";
              "fruit:posix_rename" = mkDefault "yes";
              "fruit:veto_appledouble" = mkDefault "no";
              "fruit:wipe_intentionally_left_blank_rfork" = mkDefault "yes";
              "fruit:delete_empty_adfiles" = mkDefault "yes";
            };
          };
      };

      samba-wsdd = {
        enable = mkDefault cfg.enable;
        openFirewall = mkDefault true;
      };
    };

    # Advertise Time Machine shares over mDNS. Samba here is built without
    # its own mDNS registration, so avahi does it: _adisk._tcp is what makes
    # the destination appear in System Settings, and _device-info._tcp makes
    # Finder show it as a Time Capsule rather than a generic server.
    services.avahi = mkIf (tmShares != [ ]) {
      enable = mkDefault true;
      publish = {
        enable = mkDefault true;
        userServices = mkDefault true;
      };
      extraServiceFiles.samba-timemachine = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
          <service>
            <type>_device-info._tcp</type>
            <port>0</port>
            <txt-record>model=TimeCapsule8,119</txt-record>
          </service>
          <service>
            <type>_adisk._tcp</type>
            <port>9</port>
        ${concatStringsSep "\n" (
          lib.imap0 (i: name: "    <txt-record>dk${toString i}=adVN=${name},adVF=0x82</txt-record>") tmShares
        )}
            <txt-record>sys=waMa=0,adVF=0x100</txt-record>
          </service>
        </service-group>
      '';
    };

    # Seed Samba's own password database from a secret. smbd reads it at
    # startup, so this has to land first.
    systemd.services.samba-provision-users = mkIf (cfg.passwordFile != null) {
      description = "Seed the Samba password database";
      wantedBy = [ "multi-user.target" ];
      before = [ "samba-smbd.service" ];
      requiredBy = [ "samba-smbd.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        install -d -m 0700 /var/lib/samba/private
        pw=$(cat ${toString cfg.passwordFile})
        printf '%s\n%s\n' "$pw" "$pw" \
          | ${pkgs.samba}/bin/smbpasswd -s -a ${primaryUser}
      '';
    };
  };
}
