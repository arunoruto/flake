{ config, ... }:
{
  programs.vivid.themes = {
    stylix = {
      colors = {
        inherit (config.lib.stylix.colors)
          base00
          base01
          base02
          base03
          base04
          base05
          base06
          base07
          base08
          base09
          base0A
          base0B
          base0C
          base0D
          base0E
          base0F
          ;
      };

      core = {
        normal_text = { };
        regular_file = { };
        reset_to_normal = { };

        directory.foreground = "base0D";
        symlink.foreground = "base0E";
        multi_hard_link = { };
        fifo = {
          foreground = "base01";
          background = "base0D";
        };
        socket = {
          foreground = "base01";
          background = "base0E";
        };
        door = {
          foreground = "base01";
          background = "base0E";
        };
        block_device = {
          foreground = "base0D";
          background = "base02";
        };
        character_device = {
          foreground = "base0E";
          background = "base02";
        };
        broken_symlink = {
          foreground = "base01";
          background = "base08";
        };
        missing_symlink_target = {
          foreground = "base01";
          background = "base08";
        };
        setuid = { };
        setgid = { };
        file_with_capability = { };
        sticky_other_writable = { };
        other_writable = { };
        sticky = { };
        executable_file = {
          foreground = "base08";
          font-style = "bold";
        };
      };

      text = {
        special = {
          foreground = "base00";
          background = "base0A";
        };
        todo.font-style = "bold";
        licenses.foreground = "base04";
        configuration.foreground = "base0A";
        other.foreground = "base0A";
      };

      markup.foreground = "base0A";

      programming = {
        source.foreground = "base0B";
        tooling.foreground = "base0C";
        "continuous-integration".foreground = "base0B";
      };

      media.foreground = "base0F";

      office.foreground = "base08";

      archives = {
        foreground = "base0D";
        font-style = "underline";
      };

      executable = {
        foreground = "base08";
        font-style = "bold";
      };

      unimportant.foreground = "base04";
    };

    my-awesome-theme = {
      colors = {
        black = "#000000";
        red = "#FF0000";
        green = "#00FF00";
        yellow = "#FFFF00";
        blue = "#0000FF";
        purple = "#FF00FF";
        cyan = "#00FFFF";
        orange = "#FFA500";
        white = "#FFFFFF";
        base01 = "#AAAAAA";
      };
      core = {
        "normal_text" = {
          foreground = "white";
        };
        "regular_file" = {
          foreground = "white";
        };
        "reset_to_normal" = {
          foreground = "orange";
        };
        "directory" = {
          foreground = "purple";
        };
        "symlink" = {
          foreground = "cyan";
        };
        "multi_hard_link" = { };
        "fifo" = {
          foreground = "yellow";
          background = "black";
        };
        "socket" = {
          foreground = "blue";
          background = "black";
          font-style = "bold";
        };
        "door" = {
          foreground = "blue";
          background = "black";
          font-style = "bold";
        };
        "block_device" = {
          foreground = "yellow";
          background = "black";
          font-style = "bold";
        };
        "character_device" = {
          foreground = "yellow";
          background = "black";
          font-style = "bold";
        };
        "broken_symlink" = {
          foreground = "red";
          background = "black";
          font-style = "bold";
        };
        "missing_symlink_target" = {
          foreground = "red";
          background = "black";
        };
        "setuid" = {
          foreground = "white";
          background = "red";
        };
        "setgid" = {
          foreground = "black";
          background = "yellow";
        };
        "file_with_capability" = { };
        "sticky_other_writable" = {
          foreground = "black";
          background = "green";
        };
        "other_writable" = {
          foreground = "purple";
          background = "green";
        };
        "sticky" = {
          foreground = "white";
          background = "purple";
        };
        "executable_file" = {
          foreground = "green";
        };
      };
      text = {
        "special" = {
          foreground = "orange";
        };
        "todo" = {
          foreground = "orange";
          font-style = "bold";
        };
        "licenses" = {
          foreground = "orange";
        };
        "configuration" = {
          foreground = "orange";
        };
        "other" = {
          foreground = "orange";
        };
      };
      markup = {
        foreground = "orange";
      };
      programming = {
        foreground = "orange";
      };
      media = {
        "image" = {
          foreground = "blue";
        };
        "audio" = {
          foreground = "cyan";
        };
        "video" = {
          foreground = "orange";
          font-style = "bold";
        };
        "fonts" = {
          foreground = "orange";
        };
        "3d" = {
          foreground = "blue";
        };
      };
      office = {
        foreground = "orange";
      };
      archives = {
        foreground = "red";
        font-style = "bold";
      };
      executable = {
        foreground = "green";
      };
      unimportant = {
        foreground = "base01";
      };
    };
  };
}
