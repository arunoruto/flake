{
  config,
  pkgs,
  ...
}: {
  programs = {
    # Bash
    bash.initExtra = ''eval "$(direnv hook bash)"'';

    # Htop alternative
    btop.enable = true;

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

    fd = {
      enable = true;
    };

    atuin = {
      enable = true;
      flags = [
        "--disable-up-arrow"
      ];
      enableZshIntegration = config.programs.zsh.enable;
    };

    thefuck = {
      enable = true;
      enableZshIntegration = config.programs.zsh.enable;
    };

    zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
      enableZshIntegration = config.programs.zsh.enable;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = config.programs.zsh.enable;
    };

    ripgrep = {
      enable = true;
    };
  };
}
