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
      enable = lib.mkDefault config.hosts.development.enable;
      nix-direnv.enable = true;
    };

    fd = {
      enable = true;
    };

    jq.enable = true;
    # jqp.enable = true;

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
      browsh
      firefox
    ])
  );
}
