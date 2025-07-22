{
  lib,
  config,
  ...
}:
{
  options.hypr.idle.enable = lib.mkEnableOption "Configure hypridle";

  config = lib.mkIf config.hypr.idle.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
      # NOTE: 25.11
      # systemdTarget = "hyprland-session.target";
    };

    systemd.user.services.hypridle =
      let
        session = "hyprland-session.target";
      in
      {
        Install.WantedBy = lib.mkForce [ session ];
        Unit = {
          After = lib.mkForce [ session ];
          PartOf = lib.mkForce [ session ];
        };
      };
  };
}
