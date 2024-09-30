{
  osConfig,
  pkgs,
  lib,
  user,
  ...
}: let
  # Email hash to get the gravatar image:
  # echo -n "name@example.com" | sha256sum | awk '{print $1}'
  gravatar = "4859e08193d7c964399632a8d55915804af07bf714a68aabe8bf2c2656c96f4a";
in {
  imports = [
    ./hosts
    ./pc
    ./environment.nix
    ./imports.nix
    ./stylix.nix
    ./module.nix
  ];

  pc.enable = lib.mkDefault osConfig.gui.enable;
  environment.enable = true;

  # Allow unfree software
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = user;
    homeDirectory = "/home/${user}";
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.
}
