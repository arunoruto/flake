_: {
  config = {
    home.file = {
      ".config/monitors.xml".source = ./monitors.xml;
    };

    wayland.windowManager.hyprland.settings = {
      monitor = [
        {
          output = "DP-1";
          mode = "1920x1080";
          position = "0x0";
          scale = 1;
        }
        {
          output = "DVI-I-1";
          mode = "1920x1200";
          position = "-1200x-420";
          scale = 1;
          transform = 1;
        }
      ];

      workspace_rule = [
        {
          workspace = "1";
          monitor = "DP-1";
          default = true;
        }
        {
          workspace = "2";
          monitor = "DP-1";
        }
        {
          workspace = "3";
          monitor = "DP-1";
        }
        {
          workspace = "4";
          monitor = "DP-1";
        }
        {
          workspace = "5";
          monitor = "DP-1";
        }
        {
          workspace = "6";
          monitor = "DVI-I-1";
          default = true;
        }
        {
          workspace = "7";
          monitor = "DVI-I-1";
        }
        {
          workspace = "8";
          monitor = "DVI-I-1";
        }
        {
          workspace = "9";
          monitor = "DVI-I-1";
        }
        {
          workspace = "10";
          monitor = "DVI-I-1";
        }
      ];
    };
  };
}
