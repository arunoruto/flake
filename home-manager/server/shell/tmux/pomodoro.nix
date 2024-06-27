{pkgs, ...}: let
  version = "1.0.2";
  tmux-pomodoro-plus = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "pomodoro";
    version = "${version}";
    # src = pkgs.fetchFromGitHub {
    #   owner = "arunoruto";
    #   repo = "tmux-pomodoro-plus";
    #   # rev = "v${version}";
    #   rev = "4bd8fa0a6a47a47db0b9a8022817ccdc828aff60";
    #   sha256 = "sha256-zPJ1Wavr9k4K58erDlFU/aWeM6cdliRUuUIvcb7a6zw=";
    # };
    src = builtins.fetchGit {
      url = "https://github.com/olimorris/tmux-pomodoro-plus";
      ref = "main";
    };
  };
in {
  programs.tmux = {
    plugins = [
      {
        plugin = tmux-pomodoro-plus;
        extraConfig = ''
        '';
      }
    ];
  };
  home.file.".tmux/plugins/tmux/custom/pomodoro.sh".text = ''
    # Requires https://github.com/olimorris/tmux-pomodoro-plus

    show_pomodoro() { # This function name must match the module name!
      local index icon color text module

      index=$1 # This variable is used internally by the module loader in order to know the position of this module

      icon="$(  get_tmux_option "@catppuccin_pomodoro_icon"  "🍅"           )"
      color="$( get_tmux_option "@catppuccin_pomodoro_color" "$thm_red" )"
      text="$(  get_tmux_option "@catppuccin_pomodoro_text"  " #{pomodoro_status} " )"

      module=$( build_status_module "$index" "$icon" "$color" "$text" )

      echo "$module"
    }
  '';
}
