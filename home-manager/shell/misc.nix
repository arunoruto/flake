{pkgs, ...}: {
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

    #fd = {
    #  enable = true;
    #};

    atuin = {
      enable = true;
      flags = [
        "--disable-up-arrow"
      ];
    };

    thefuck = {
      enable = true;
    };

    zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    ripgrep = {
      enable = true;
    };
  };
}
