{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./zigbee2mqtt.nix
  ];
  services = {
    home-assistant = lib.mkIf config.services.home-assistant.enable {
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
        "radio_browser"
        "shopping_list"
      ];
      customComponents = with pkgs.home-assistant-custom-components; [
        hass-ingress
      ];
    };
    mosquitto.enable = true;
    zigbee2mqtt.enable = false;
  };
}
