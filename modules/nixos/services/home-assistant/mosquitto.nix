{
  lib,
  pkgs,
  config,
  ...
}:
let
  port = 1883;
in
{
  config = lib.mkIf config.services.mosquitto.enable {
    services.mosquitto = {
      package = pkgs.unstable.mosquitto;
      listeners = [
        {
          # port = "${port} 0.0.0.0";
          # inherit port;
          # address = "0.0.0.0";
          users = {
            hassio.password = "hassio";
            zigbee2mqtt.password = "mqtt2zigbee";
            tasmota.password = "socket";
          };
        }
      ];
      # settings = {
      #   pattern = "readwrite #";
      # };
    };
    networking.firewall.allowedTCPPorts = [ port ];
  };
}
