{ config, lib, ... }:
{
  programs = {
    helix.settings.keys = {
      normal = {
        X = [
          "extend_line_up"
          "extend_to_line_bounds"
        ];
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
        "C-e" = [
          ":sh rm -f /tmp/unique-file"
          ":insert-output ${lib.getExe config.programs.yazi.package} %{buffer_name} --chooser-file=/tmp/unique-file"
          ":insert-output echo '\x1b[?1049h\x1b[?2004h' > /dev/tty"
          ":open %sh{cat /tmp/unique-file}"
          ":redraw"
          ":set mouse false"
          ":set mouse true"
        ];
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
