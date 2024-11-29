{
  programs = {
    helix.settings.keys = {
      normal = {
        space.W = [ ":toggle soft-wrap.enable" ];
        space.X = [ ":buffer-close" ];
        # space.b = {
        #   p = "buffer_picker";
        #   h = "goto_previous_buffer";
        #   l = "goto_next_buffer";
        #   x = ":buffer-close";
        # };
      };
      insert = {
        "C-space" = "signature_help";
      };
    };

    tmux.extraConfig = ''
      set -sg escape-time 10
    '';
  };
}
