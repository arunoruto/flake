{
  config,
  pkgs,
  lib,
  inputs,
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
  imports = [
    inputs.direnv-instant.homeModules.direnv-instant
    # ./vivid-module.nix
    # ./vivid-filetype.nix
    ./vivid-themes.nix
  ];

  programs = {
    # Bash
    # bash.initExtra = lib.optionalString config.programs.direnv.enable ''eval "$(direnv hook bash)"'';

    direnv =
      let
        instant = (config.programs ? direnv-instant) && config.programs.direnv-instant.enable;
      in
      {
        enable = config.hosts.development.enable;
        # enable = lib.mkDefault config.hosts.development.enable;
        # enableBashIntegration = lib.mkForce (!instant);
        # enableFishIntegration = lib.mkForce (!instant);
        # enableNushellIntegration = lib.mkForce (!instant);
        # enableZshIntegration = lib.mkForce (!instant);
        nix-direnv.enable = true;
      };

    direnv-instant.enable = true;

    fd = {
      enable = true;
    };

    jq.enable = true;
    # jqp.enable = true;

    ripgrep = {
      enable = true;
    };

    skim.enable = true;

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
