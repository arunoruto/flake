{ lib, config, ... }:
{
  options.skim.enable = lib.mkEnableOption "Enable skim for fuzzy finding; alternative to fzf";

  config = lib.mkIf config.skim.enable {
    programs.skim = {
      enable = true;
      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      # enableNushellIntegration = config.programs.nushell.enable;
      enableZshIntegration = config.programs.zsh.enable;
    };
  };
}
