{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.distrobox;
in
{
  options.programs.distrobox = {
    enable = lib.mkEnableOption "Enable distrobox";
    package = lib.mkPackageOption pkgs "distrobox" { };
    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = with lib.types; attrsOf anything;
        options = {
          container_additional_volumes = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "/nix/store:/nix/store:ro"
              "/etc/profiles/per-user:/etc/profiles/per-user:ro"
              "/etc/static/profiles/per-user:/etc/static/profiles/per-user:ro"
            ];
            description = ''
              List of volumes to mount automatically into the container.
              Defaults to mounting /nix/store to ensure host binaries work.
            '';
          };
          container_always_pull = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "If true, always pull the image before creating.";
          };
        };
      };
      default = { };
      description = ''
        Configuration written to /etc/distrobox/distrobox.conf.
        See https://distrobox.it/ for available keys.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment = {
          systemPackages = [ cfg.package ];
          etc."distrobox/distrobox.conf".text = lib.generators.toKeyValue {
            mkKeyValue =
              key: value:
              if (lib.isList value) then
                ''${key}="${lib.concatStringsSep " " (lib.map builtins.toString value)}"''
              else
                ''${key}="${builtins.toString value}"'';
          } cfg.settings;
        };
      }
      (lib.mkIf (!config.virtualisation.docker.enable) {
        virtualisation.podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true;
        };
      })
    ]
  );
}
