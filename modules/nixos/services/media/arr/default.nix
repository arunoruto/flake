{
  config,
  lib,
  ...
}:
let
  # The servarr services that write into the media libraries. prowlarr is left
  # out on purpose: it only manages indexers and never touches media files.
  mediaWriters = builtins.filter (name: config.services.${name}.enable or false) [
    "radarr"
    "sonarr"
    "lidarr"
    "readarr"
    "bazarr"
  ];
in
{
  imports = [
    ./bazarr.nix
    ./sonarr.nix
    ./radarr.nix
    ./lidarr.nix
    ./readarr.nix
    ./recyclar.nix
    ./prowlarr.nix
  ];

  options.services.arr.enable = lib.mkEnableOption "Enable arr frameworks";

  config = lib.mkIf config.services.arr.enable {
    # Everything else about bazarr lives in ./bazarr.nix, the same way each
    # servarr service does; the arr framework only decides that it is on.
    # dataDir is left at the upstream default on purpose -- moving it would
    # strand the existing config under /var/lib/bazarr.
    services.bazarr.enable = lib.mkDefault true;

    systemd.services = lib.genAttrs mediaWriters (_: {
      # The upstream servarr modules hardcode UMask=0022, which makes every
      # imported file and folder group-read-only. Combined with the setgid bit
      # from services.media.libraryDirs, 0002 keeps imports writable by the
      # shared `media` group instead of only by the importing service.
      serviceConfig.UMask = lib.mkForce "0002";
    });

    # Upstream only tmpfiles-creates the dataDir itself, so a file inside it that
    # ends up owned by someone else (a restore or a copy done as root) stays
    # unwritable forever -- radarr then fails to persist config.xml on every
    # start. Re-assert ownership of the contents, leaving modes alone.
    systemd.tmpfiles.settings."10-arr-data" = builtins.listToAttrs (
      map (name: {
        name = config.services.${name}.dataDir;
        value.Z = {
          user = config.services.${name}.user or name;
          group = config.services.${name}.group or name;
        };
      }) (builtins.filter (name: config.services.${name} ? dataDir) mediaWriters)
    );
  };
}
