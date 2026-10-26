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
    # This host is the *source* side: the downloaders write into
    # completedPath and syncthing pushes the per-consumer folders out to the
    # hosts running the *arrs. The folders themselves, and the devices they are
    # shared with, are declared in ../syncthing/folders.nix — only the peers
    # this host dials that are not covered there live here.
    services.syncthing = {
      enable = true;

      settings.devices = {
        # lil-nas-x = {
        #   addresses = [
        #     "dynamic"
        #     "tcp://lil-nas-x"
        #     "tcp://lil-nas-x:22000"
        #     "quic://lil-nas-x:22000"
        #   ];
        #   id = "ARZDFKU-CFAXQEM-ZTBEVH6-DGU7E55-JNLRTVM-VKG7JW5-D6B25X3-IRPISQH";
        # };
        kuchiki = {
          addresses = [
            "dynamic"
            "tcp://kuchiki"
            "tcp://kuchiki:22000"
            "quic://kuchiki:22000"
          ];
          id = "C4TO46K-P5LXFD6-NULLWDR-A5MYGJ2-EQDBNOC-CZHYJNJ-33DJHWA-SPQ6RQ7";
        };
      };
    };
  };
}
