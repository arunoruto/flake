{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  imports = [
    ./mosquitto.nix
    ./zigbee2mqtt.nix
  ];
  config = lib.mkIf config.services.home-assistant.enable {
    services = {
      home-assistant = {
        package = pkgs.unstable.home-assistant;
        config = {
          homeassistant = {
            # auth_providers = [ { type = homeassistant; } ];
            # allowlist_external_dirs = [ "/config" ];
          };
          http = {
            use_x_forwarded_for = true;
            trusted_proxies = [
              "::1"
              "127.0.0.1"
              "10.42.42.0/24"
              # "172.30.33.0/24"
            ];
          };

          default_config = { };
        };
        extraComponents = [
          "analytics"
          "cast"
          "google_translate"
          "isal"
          "met"
          "mqtt"
          "radio_browser"
          "shopping_list"
          "tasmota"
        ];
        customComponents =
          let
            pkgs-extended = pkgs.extend self.overlays.home-assistant;
          in
          with pkgs-extended.home-assistant-custom-components;
          (lib.optionals (config.services.home-assistant.config ? "ingress") [
            hass-ingress
          ]);
      };
      mosquitto.enable = true;
      zigbee2mqtt.enable = true;
    };
  };
}
