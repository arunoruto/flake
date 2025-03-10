{ ... }:
{
  config = {
    # dconf.settings = {
    #   "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = lib.mkForce {
    #     name = "Terminal Super";
    #     #command = "env WAYLAND_DISPLAY= alacritty";
    #     #command = "wezterm start --always-new-process";
    #     command = "${lib.getExe pkgs.alacritty}";
    #     binding = "<Super>Return";
    #   };
    # };
    # terminals.alacritty.enable = true;

    home.file = {
      ".config/monitors.xml".source = ./monitors.xml;
    };

    wayland.windowManager.hyprland.settings = {
      monitor = [
        "DP-1,   1920x1080,0x0,1"
        "DVI-I-1,1920x1200,-1200x-420,1,transform,1"
      ];

      workspace = [
        "1,  monitor:DP-1"
        "2,  monitor:DP-1"
        "3,  monitor:DP-1"
        "4,  monitor:DP-1"
        "5,  monitor:DP-1"
        "6,  monitor:DVI-I-1"
        "7,  monitor:DVI-I-1"
        "8,  monitor:DVI-I-1"
        "9,  monitor:DVI-I-1"
        "10, monitor:DVI-I-1"
      ];
    };
  };
}
