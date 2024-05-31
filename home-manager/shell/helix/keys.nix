{
  programs.helix.settings.keys = {
    normal = {
      space.W = [":toggle soft-wrap.enable"];
      b = {
        p = "buffer_picker";
        h = "goto_previous_buffer";
        l = "goto_next_buffer";
        x = ":buffer-close";
      };
    };
  };
}
