{
  programs = {
    helix.settings.keys = {
      normal = {
        space.W = [ ":toggle soft-wrap.enable" ];
        space.X = [ ":buffer-close" ];
        space.i = {
          e = ":toggle end-of-line-diagnostics warning disable";
          c = ":toggle inline-diagnostics.cursor-line hint disable";
          o = ":toggle inline-diagnostics.other-lines error disable";
        };
        # space.b = {
        #   p = "buffer_picker";
        #   h = "goto_previous_buffer";
        #   l = "goto_next_buffer";
        #   x = ":buffer-close";
        # };
      };
      insert = {
        "C-p" = "signature_help";
        "C-space" = "signature_help";
      };
    };

    tmux.extraConfig = ''
      set -sg escape-time 10
    '';
  };
}
