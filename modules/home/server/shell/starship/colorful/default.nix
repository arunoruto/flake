{ pkgs, lib, ... }:
let
  flavour = "macchiato";
  catppuccin-starship = builtins.fetchGit {
    url = "https://github.com/catppuccin/starship";
    ref = "main";
  };
in
{
  programs.starship = {
    enable = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      # add_newline = false;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      format = lib.concatStrings [
        "[](surface0)"
        "$os"
        "$username"
        "[](fg:surface0 bg:surface1)"
        "$directory"
        "[](fg:surface1 bg:red)"
        "$git_branch"
        "$git_status"
        "[](fg:red bg:peach)"
        "$c"
        "$elixir"
        "$elm"
        "$golang"
        "$gradle"
        "$haskell"
        "$java"
        "$julia"
        "$nodejs"
        "$nim"
        "$rust"
        "$scala"
        "[](fg:peach bg:blue)"
        "$docker_context"
        "[](fg:blue bg:green)"
        "$time"
        "[ ](fg:green)"
      ];

      username = {
        show_always = true;
        style_user = "fg:text bg:surface0";
        style_root = "fg:#ffffff bg:#ff0000";
        format = "[$user ]($style)";
        disabled = false;
      };

      # An alternative to the username module which displays a symbol that
      # represents the current operating system
      os = {
        style = "fg:text bg:surface0";
        disabled = false; # Disabled by default
      };

      directory = {
        style = "fg:text bg:surface1";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      # Here is how you can shorten some long paths by text replacement
      # similar to mapped_locations in Oh My Posh:
      directory.substitutions = {
        "Documents" = "󰈙 ";
        "Downloads" = " ";
        "Music" = " ";
        "Pictures" = " ";
        # Keep in mind that the order matters. For example:
        # "Important Documents" = " 󰈙 "
        # will not be replaced, because "Documents" was already substituted before.
        # So either put "Important Documents" before "Documents" or use the substituted version:
        # "Important 󰈙 " = " 󰈙 "
      };

      c = {
        symbol = " ";
        style = "fg:surface0 bg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      docker_context = {
        symbol = " ";
        style = "fg:surface0 bg:blue";
        format = "[ $symbol $context ]($style)";
      };

      elixir = {
        symbol = " ";
        style = "fg:surface0 bg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      elm = {
        symbol = " ";
        style = "fg:surface0 bg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      git_branch = {
        symbol = "";
        style = "fg:surface0 bg:red";
        format = "[ $symbol $branch ]($style)";
      };

      git_status = {
        style = "fg:surface0 bg:red";
        format = "[$all_status$ahead_behind ]($style)";
      };

      golang = {
        symbol = " ";
        style = "fg:surface0 bg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      gradle = {
        style = "fg:surface0 bg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      haskell = {
        symbol = " ";
        style = "fg:surface0 bg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      java = {
        symbol = " ";
        style = "fg:surface0 bg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      julia = {
        symbol = " ";
        style = "fg:surface0 bg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      nodejs = {
        symbol = "";
        style = "fg:surface0 bg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      nim = {
        symbol = "󰆥 ";
        style = "fg:surface0 bg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      rust = {
        symbol = "";
        style = "fg:surface0 bg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      scala = {
        symbol = " ";
        style = "fg:surface0 bg:peach";
        format = "[ $symbol ($version) ]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R"; # Hour:Minute Format
        style = "fg:surface0 bg:green";
        format = "[ 󱑆 $time ]($style)";
      };

      # package.disabled = true;
      palette = "catppuccin_${flavour}";
    } // builtins.fromTOML (builtins.readFile (catppuccin-starship + /palettes/${flavour}.toml));
  };
}
