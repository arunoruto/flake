{
  config,
  pkgs,
  lib,
  ...
}@args:
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
  imports = [
    ./vivid-module.nix
    ./vivid-filetype.nix
    ./vivid-themes.nix
  ];

  programs = {
    atuin = {
      enable = true;
      flags = [
        "--disable-up-arrow"
      ];
    };

    # Bash
    bash.initExtra = ''eval "$(direnv hook bash)"'';

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fd = {
      enable = true;
    };

    thefuck = {
      enable = true;
      enableInstantMode = (args ? nixosConfig);
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

    skim.enable = true;

    vivid = {
      enable = true;
      package = pkgs.unstable.vivid;
      theme = "gruvbox-dark";
    };

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
