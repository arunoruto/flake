{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf (with config.services; (zigbee2mqtt.enable && mosquitto.enable)) {
    services = {
      zigbee2mqtt = {
        package = pkgs.unstable.zigbee2mqtt;
        settings = {
          homeassistant.enabled = config.services.home-assistant.enable;
          frontend = {
            enabled = true;
            port = 8080;
          };
          # serial = {
          #   # port = "tcp://10.42.42.69:6638";
          #   # baudrate = 115200;
          #   # adapter = "zstack";
          #   # disable_led = false;
          # };
        };
      };
      home-assistant.config =
        lib.optionalAttrs
          (lib.elem pkgs.home-assistant-custom-components.hass-ingress config.services.home-assistant.customComponents)
          {
            ingress.zigbee2mqtt = {
              work_mode = "ingress";
              ui_mode = "normal";
              title = "Zigbee2MQTT";
              icon = "mdi:bee";
              url = "localhost";
            };
          };
    };
  };
}
