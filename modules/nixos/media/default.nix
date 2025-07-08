{
  config,
  lib,
  ...
}:
{
  imports = [
    ./arr.nix
    ./bosflix.nix
    ./external-drives.nix
    ./jellyfin.nix
    ./paperless.nix
    ./plex.nix
    ./qbittorrent.nix
  ];

  options.services.media = {
    enable = lib.mkEnableOption "Enable media services";
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/media";
      description = "Directory to store media data";
    };
    openFirewall = lib.mkEnableOption "Open all firewall ports of media services";
  };

  config = lib.mkIf config.services.media.enable {
    services = {
      arr.enable = lib.mkDefault true;
      jellyfin.enable = lib.mkDefault true;
      plex.enable = lib.mkDefault true;
    };

    media.external-drives.enable = lib.mkDefault true;
  };
}
