{ lib, ... }:
{
  systemd = {
    network = {
      # enable = false;
      wait-online.enable = false;
    };
    services = {
      # NetworkManager-wait-online.serviceConfig = {
      #   Environment = "SYSTEMD_LOG_LEVEL=debug";
      # };
      systemd-networkd-wait-online = {
        serviceConfig = {
          Environment = "SYSTEMD_LOG_LEVEL=debug";
        };
      };

      # chrome-killer = {
      #   #wantedBy = [ "multi-user.target" ];
      #   #after = [ "final.target" ];
      #   wantedBy = [ "final.target" ];
      #   after = [ "final.target" ];
      #   description = "Kill chrome during shutdown";
      #   serviceConfig = {
      #     Type = "oneshot";
      #     #User = "mirza";
      #     #RemainAfterExit = true;
      #     #ExecStop = ''killall chrome'';
      #     ExecStart = ''/run/current-system/sw/bin/killall chrome'';
      #   };
      # };
    };
  };
}
