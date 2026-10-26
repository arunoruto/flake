{
  config,
  lib,
  ...
}:
let
  cfg = config.services.bosflix;
in
{
  config = lib.mkIf cfg.enable {
    # Disabled on purpose and kept as a reference: qbittorrent (see
    # ../downloaders/qbittorrent.nix) is what actually handles torrents here.
    # The paths are wired up so that re-enabling it is a one-line change rather
    # than an archaeology exercise.
    services = {
      deluge = {
        enable = false;
        web.enable = true;
        # declarative = true;
        config = {
          download_location = cfg.incompletedPath;
          move_completed = true;
          move_completed_path = cfg.completedPath;

          enabled_plugins = [ "Label" ];
        };
      };

      # transmission = {
      #   enable = true;
      # };
    };
  };
}
