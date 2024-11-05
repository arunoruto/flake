{ config, lib, ... }:
{
  imports = [
    ./definitions
  ];

  programs.starship = {
    enable = true;
    enableBashIntegration = lib.mkDefault config.programs.bash.enable;
    enableFishIntegration = lib.mkDefault config.programs.fish.enable;
    enableNushellIntegration = lib.mkDefault config.programs.nushell.enable;
    enableZshIntegration = lib.mkDefault config.programs.zsh.enable;
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
    };
  };
}
