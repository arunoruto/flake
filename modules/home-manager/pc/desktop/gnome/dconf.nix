{
  lib,
  config,
  ...
}: {
  options.gnome.dconf.enable = lib.mkEnableOption "Configure GNOME thorugh custom dconf";

  config = lib.mkIf config.gnome.dconf.enable {
    dconf.settings = {
      # Time zone settings
      # "org/gnome/desktop/datetime" = {automatic-timezone = true;};
      "org/gnome/system/location" = {enabled = true;};
      # Wallpaper settings
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        # picture-uri = wallpaper;
        # picture-uri-dark = wallpaper;
      };
      # Additional window buttons
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,close";
      };
      # Input settings
      "org/gnome/desktop/input-sources" = {
        # if this doesn't work, try the following command
        # gsettings reset org.gnome.desktop.input-sources sources
        # gsettings reset org.gnome.desktop.input-sources xkb-options
        # sources = [];
        # xkb-options = [];
      };
      # Mouse and touchpad settings
      "org/gnome/desktop/peripherals/touchpad" = {
        # speed = 0.0;
        # tap-to-click = true;
        two-finger-scrolling-enabled = true;
        natural-scroll = true;
        edge-scrolling-enabled = false;
      };
      # Set some interface options found in tweaks
      "org/gnome/desktop/interface" = {
        show-battery-percentage = true;
        #  color-scheme = "default";
        #  cursor-theme = "Catppuccin-Macchiato-Dark-Cursors";
        # gtk-theme = lib.mkForce "Catppuccin-Macchiato-Standard-Green-Dark";
        icon-theme = lib.mkForce "candy-icons";
      };
      # Set list of custom keybinding
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          #"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        ];
      };
      # The keybindings to mention above
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Terminal Super";
        #command = "env WAYLAND_DISPLAY= alacritty";
        #command = "wezterm start --always-new-process";
        command = "wezterm";
        binding = "<Super>Return";
      };
      #"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      #  name = "Tailscale Switch";
      #  command = "tailscale switch $(tailscale switch --list | tail -n +2 | rofi -dmenu | cut -d' ' -f1)";
      #  binding = "<Shift><Super>t";
      #};
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = "emoji picker";
        command = "flatpak run it.mijorus.smile";
        binding = "<Control>less";
      };
      # i3 keybindings
      "org/gnome/mutter".dynamic-workspaces = false;
      "org/gnome/desktop/wm/preferences".num-workspaces = 9;
      "org/gnome/shell/keybindings" = {
        switch-to-application-1 = [];
        switch-to-application-2 = [];
        switch-to-application-3 = [];
        switch-to-application-4 = [];
        switch-to-application-5 = [];
        switch-to-application-6 = [];
        switch-to-application-7 = [];
        switch-to-application-8 = [];
        switch-to-application-9 = [];
      };
      "org/gnome/desktop/wm/keybindings" = {
        close = [
          "<Alt>F4"
          "<Super><Shift>q"
        ];
        switch-to-workspace-1 = ["<Super>1"];
        switch-to-workspace-2 = ["<Super>2"];
        switch-to-workspace-3 = ["<Super>3"];
        switch-to-workspace-4 = ["<Super>4"];
        switch-to-workspace-5 = ["<Super>5"];
        switch-to-workspace-6 = ["<Super>6"];
        switch-to-workspace-7 = ["<Super>7"];
        switch-to-workspace-8 = ["<Super>8"];
        switch-to-workspace-9 = ["<Super>9"];
        move-to-workspace-1 = ["<Super><Shift>1"];
        move-to-workspace-2 = ["<Super><Shift>2"];
        move-to-workspace-3 = ["<Super><Shift>3"];
        move-to-workspace-4 = ["<Super><Shift>4"];
        move-to-workspace-5 = ["<Super><Shift>5"];
        move-to-workspace-6 = ["<Super><Shift>6"];
        move-to-workspace-7 = ["<Super><Shift>7"];
        move-to-workspace-8 = ["<Super><Shift>8"];
        move-to-workspace-9 = ["<Super><Shift>9"];
      };
      "com/github/stunkymonkey/nautilus-open-any-terminal" = {
        terminal = "wezterm";
      };
    };
  };
}
