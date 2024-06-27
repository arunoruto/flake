{
  programs = {
    helix.settings.keys = {
      normal = {
        space.W = [":toggle soft-wrap.enable"];
        space.b = {
          p = "buffer_picker";
          h = "goto_previous_buffer";
          l = "goto_next_buffer";
          x = ":buffer-close";
        };
      };
    };

    tmux.extraConfig = ''
      set -sg escape-time 10
    '';
  };
}
