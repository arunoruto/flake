_: {
  config = {
    wayland.windowManager.hyprland.settings = {
      monitor = [
        # Empty output = the fallback rule for every monitor without one.
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1.175;
        }
      ];
    };
  };
}
