{
  inputs,
  config,
  pkgs,
  lib,
  username,
  theme,
  image,
  ...
}: {
  sops.secrets."passwords/${username}".neededForUsers = true;

  users = {
    # mutableUsers = false;
    users.${username} = {
      isNormalUser = true;
      # hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
      shell = pkgs.zsh;
      description = "Mirza";
      extraGroups = [
        "dialout"
        "networkmanager"
        "wheel"
        "scanner"
        "lp"
        "pipewire"
        "audio"
        "video"
        "render"
        "input"
        "uinput"
      ];
    };
  };

  programs.zsh.enable = true;

  environment.sessionVariables.FLAKE = "/home/${username}/.config/flake";

  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
    image =
      pkgs.fetchFromGitHub {
        owner = "arunoruto";
        repo = "wallpapers";
        rev = "8815698729ceff1f97fae5ab2bf930a9dd682198";
        hash = "sha256-uPaPAggLFmureDXqKcvwr2uMb24QuxQzbwCqTHNSIrg=";
      }
      + "/${image}";
    # + "/art/kanagawa/kanagawa-van-gogh.jpg";
    cursor = {
      name = "catppuccin-macchiato-dark-cursors";
      package = pkgs.catppuccin-cursors.macchiatoDark;
    };
    targets = {
      lightdm.enable = true;
    };
  };
}
