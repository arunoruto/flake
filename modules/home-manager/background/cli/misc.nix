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
    # ./vivid-module.nix
    # ./vivid-filetype.nix
    ./vivid-themes.nix
  ];

  programs = {
    # Bash
    bash.initExtra = ''eval "$(direnv hook bash)"'';

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fd = {
      enable = true;
    };

    jq.enable = true;
    # jqp.enable = true;

    # lsd is an ls replacement
    lsd = {
      enable = true;
      # enableAliases = true;
      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
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
        date = "+%F %T";
        sorting = {
          dir-grouping = "first";
        };
      };
    };

    ripgrep = {
      enable = true;
    };

    skim.enable = true;

    # thefuck = {
    #   enable = true;
    #   enableInstantMode = args ? nixosConfig;
    # };

    vivid = {
      enable = true;
      package = pkgs.unstable.vivid;
      activeTheme = "nord";
      # enableSessionVariables = true;
      # activeTheme = "stylix";
      # activeTheme = "gruvbox-dark";
    };

    zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
    };
  };

  home.packages = lib.optionals config.hosts.development.enable (
    (with pkgs; [
      broot
      fx
      gping
      up
      poppler-utils
      q
    ])
    ++ (with pkgs.unstable; [
      devenv
    ])
  );
}
