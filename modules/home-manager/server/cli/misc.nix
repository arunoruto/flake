{
  config,
  pkgs,
  lib,
  ...
}:
# let
#   aliases = {
#     ls = "${pkgs.lsd}/bin/lsd";
#     ll = "${pkgs.lsd}/bin/lsd -l";
#     la = "${pkgs.lsd}/bin/lsd -A";
#     lt = "${pkgs.lsd}/bin/lsd --tree";
#     lla = "${pkgs.lsd}/bin/lsd -lA";
#     llt = "${pkgs.lsd}/bin/lsd -l --tree";
#   };
# in
{
  programs = {
    atuin = {
      enable = true;
      flags = [
        "--disable-up-arrow"
      ];
    };

    # Bash
    bash.initExtra = ''eval "$(direnv hook bash)"'';

    # Htop alternative
    btop.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fd = {
      enable = true;
    };

    thefuck = {
      enable = true;
      enableInstantMode = true;
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
    # };

    zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
    };
  };

  home.packages = with pkgs; [
    broot
    devenv
    fx
    gping
    up
    q
  ];
}
