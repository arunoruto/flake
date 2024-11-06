{
  config,
  pkgs,
  lib,
  ...
}:
let
  #   aliases = {
  #     ls = "${pkgs.lsd}/bin/lsd";
  #     ll = "${pkgs.lsd}/bin/lsd -l";
  #     la = "${pkgs.lsd}/bin/lsd -A";
  #     lt = "${pkgs.lsd}/bin/lsd --tree";
  #     lla = "${pkgs.lsd}/bin/lsd -lA";
  #     llt = "${pkgs.lsd}/bin/lsd -l --tree";
  #   };

  enableBashIntegration = lib.mkDefault config.programs.bash.enable;
  enableFishIntegration = lib.mkDefault config.programs.fish.enable;
  enableNushellIntegration = lib.mkDefault config.programs.nushell.enable;
  enableZshIntegration = lib.mkDefault config.programs.zsh.enable;
in
{
  programs = {
    atuin = {
      enable = true;
      flags = [
        "--disable-up-arrow"
      ];
      inherit enableBashIntegration;
      inherit enableFishIntegration;
      inherit enableNushellIntegration;
      inherit enableZshIntegration;
    };

    # Bash
    bash.initExtra = ''eval "$(direnv hook bash)"'';

    # Htop alternative
    btop.enable = true;

    # completion manager
    carapace = {
      enable = true;
      inherit enableBashIntegration;
      inherit enableFishIntegration;
      inherit enableNushellIntegration;
      inherit enableZshIntegration;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      inherit enableBashIntegration;
      # inherit enableFishIntegration;
      inherit enableNushellIntegration;
      inherit enableZshIntegration;
    };

    fd = {
      enable = true;
    };

    thefuck = {
      enable = true;
      inherit enableBashIntegration;
      inherit enableFishIntegration;
      inherit enableNushellIntegration;
      inherit enableZshIntegration;
    };

    # lsd is an ls replacement
    lsd = {
      enable = true;
      enableAliases = true;
      settings = {
        ignore-globs = [
          ".DS_Store"
        ];
        blocks = [
          "permission"
          "user"
          "group"
          "size"
          "date"
          "git"
          "name"
        ];
        date = "+%a %d.%m.%y %X";
        sorting = {
          dir-grouping = "first";
        };
      };
    };
    # nushell.shellAliases = lib.mkIf config.programs.nushell.enable aliases;

    ripgrep = {
      enable = true;
    };

    # vivid = {
    #   enable = true;
    #   theme = "gruvbox-dark";
    #   inherit enableBashIntegration;
    #   inherit enableFishIntegration;
    #   inherit enableNushellIntegration;
    #   inherit enableZshIntegration;
    # };

    zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
      inherit enableBashIntegration;
      inherit enableFishIntegration;
      inherit enableNushellIntegration;
      inherit enableZshIntegration;
    };
  };

  home.packages = with pkgs; [
    devenv
  ];
}
