{
  inputs,
  pkgs,
  lib,
  username,
  theme,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
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
    ];
  };

  programs.zsh.enable = true;

  environment.sessionVariables.FLAKE = "/home/${username}/.config/flake";

  # catppuccin = {
  #   enable = true;
  #   flavor = "macchiato";
  #   accent = "green";
  # };
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
        rev = "0814f66ec93e546c57bef0bdf5bf60cde401cf32";
        hash = "sha256-sCVHHUK13BiN6c+13Ca1wQidmBvrDoGBuJGlg2pXuo4=";
      }
      + "/art/kanagawa/kanagawa-van-gogh.jpg";
    cursor = {
      name = "catppuccin-macchiato-dark-cursors";
      package = pkgs.catppuccin-cursors.macchiatoDark;
    };
    targets = {
      lightdm.enable = true;
    };
  };
}
