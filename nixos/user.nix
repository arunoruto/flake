{
  inputs,
  pkgs,
  lib,
  username,
  theme,
  image,
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
        rev = "fbc9afaaac0fb40ac81ff054ddae9660a7716574";
        hash = "sha256-DQGrrFDSAHLJMj26inTxk7jiLFm3cLI4jgCZX1mNZhA=";
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
