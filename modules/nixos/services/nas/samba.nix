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

    disableShares = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Share names to disable (blacklist)";
    };

  };

  config = mkIf cfg.enable {
    services.samba.openFirewall = mkDefault true;

    services.samba.settings =
      let
        active = filterAttrs (name: _: !(elem name cfg.disableShares)) cfg.directories;
      in
      (builtins.mapAttrs (_: share: {
        path = share.path;
        browseable = if share.browseable then "yes" else "no";
        "read only" = if share.writable then "no" else "yes";
        "guest ok" = if share.guestOk then "yes" else "no";
        "valid users" = concatStringsSep " " share.users;
        "force user" = builtins.head share.users;
        comment = share.comment;
      }) active)
      // {
        global = {
          "server min protocol" = mkDefault "SMB2_10";
          "client min protocol" = mkDefault "SMB2_10";
          "map to guest" = mkDefault "Bad User";
        };
      };

    # services.samba.settings.global = {
    #   "server min protocol" = mkDefault "SMB2_10";
    #   "client min protocol" = mkDefault "SMB2_10";
    #   "map to guest" = mkDefault "Bad User";
    # };

    services.samba-wsdd = {
      enable = mkDefault cfg.enable;
      openFirewall = mkDefault true;
    };

  };
}
