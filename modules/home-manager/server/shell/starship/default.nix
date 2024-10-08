{config, ...}: let
  flavour = "macchiato";
  catppuccin-starship = "";
  #catppuccin-starship = builtins.fetchGit {
  #  url = "https://github.com/catppuccin/starship";
  #  ref = "main";
  #};
in {
  imports = [
    ./definitions
  ];

  programs.starship = {
    enable = true;
    enableZshIntegration = config.programs.zsh.enable;
    settings = {
      format = "$hostname$directory$character";
      # format = "$directory";
      right_format = "$all";
      add_newline = true;
      character = {
        success_symbol = "[[❄](green) ❯](maroon)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };
      hostname = {
        ssh_only = true;
        style = "bold dimmed green";
        format = "[$ssh_symbol$hostname]($style): ";
      };
      directory = {
        truncation_length = 2;
        truncation_symbol = "../";
        style = "bold lavender";
      };
      #palette = "catppuccin_${flavour}";
    };
    #// builtins.fromTOML (builtins.readFile(catppuccin-starship + /palettes/${flavour}.toml));
  };
}
