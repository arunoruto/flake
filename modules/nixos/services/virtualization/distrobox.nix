{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.virtualisation.distrobox;
in
{
  options.virtualisation.distrobox = {
    enable = lib.mkEnableOption "Enable distrobox";
    package = lib.mkPackageOption pkgs "distrobox" { };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [ cfg.package ];
      etc."distrobox/distrobox.conf".text = ''
        container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro"
      '';
    };
  };
  # // (
  #   if config.virtualisation.podman.enable then
  #     { virtualisation.podman.dockerCompat = lib.mkDefault true; }
  #   else
  #     { virtualisation.docker.enable = lib.mkDefault true; }
  # );
}
