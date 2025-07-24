{
  inputs,
  config,
  pkgs,
  lib,
  osConfig,
  ...
}@args:
{
  options.stylix.monitors = lib.mkOption {
    # type = lib.types.str;
    default = null;
    example = lib.literalExample ''
      {
        "0" = {
          enable = true;
          connector = "eDP-1";
          x = 0;
          y = 0;
          gnomeScale = "1.2512478828430176";
          gnomeRate = 59.999;
          hyprScale = "1.175";
          primary = true;
          rate = 60;
        };
      };
    '';
    description = ''
      Monitor setup.
    '';
  };

  config =
    let
      cfg = config.stylix.monitors;
    in
    lib.mkIf
      (
        cfg != null && args ? nixosConfig && osConfig ? facter && osConfig.facter.report.hardware ? monitor
      )
      {

        wayland.windowManager.hyprland = {
          settings = {
            monitor = builtins.map (
              monitor:
              let
                selected = cfg.${monitor.serial};
              in
              if selected.enable then
                (builtins.concatStringsSep "," [
                  selected.connector
                  "preferred"
                  "auto"
                  (builtins.toString (if selected ? hyprScale then selected.hyprScale else selected.rate))
                ])
              else
                ""
            ) osConfig.facter.report.hardware.monitor;
          };
        };

        # Gnome
        home.file.".config/monitors.xml".text = ''
          <monitors version="2">
          <configuration>

        ''
        + builtins.concatStringsSep "\n" (
          builtins.map (
            monitor:
            let
              selected = cfg.${monitor.serial};
            in
            ''
              <logicalmonitor>
                <x>${builtins.toString selected.x}</x>
                <y>${builtins.toString selected.y}</y>
                <scale>${if (selected ? gnomeScale) then selected.gnomeScale else selected.scale}</scale>
                <primary>${if selected.primary then "yes" else "no"}</primary>
                <monitor>
                  <monitorspec>
                    <connector>${selected.connector}</connector>
                    <vendor>${if monitor.vendor.name == "BOE CQ" then "BOE" else monitor.vendor.name}</vendor>
                    <product>0x${monitor.device.hex}</product>
                    <serial>${if (monitor.serial == "0") then "0x00000000" else monitor.serial}</serial>
                  </monitorspec>
                  <mode>
                    <width>${builtins.toString monitor.detail.width}</width>
                    <height>${builtins.toString monitor.detail.height}</height>
                    <rate>${
                      builtins.toString (if selected ? gnomeRate then selected.gnomeRate else selected.rate)
                    }</rate>
                  </mode>
                </monitor>
              </logicalmonitor>
            ''
          ) osConfig.facter.report.hardware.monitor
        )
        + ''

          </configuration>
          </monitors>
        '';
      };
}
