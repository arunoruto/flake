{ config, ... }:
let
  user = config.user;
in
{
  imports = [
    # ./hosts
    ./environment.nix
    ./imports.nix
  ];

  environment.enable = true;

  # Allow unfree software
  # nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # For development
  # programs.home-manager.path = "/home/${config.home.username}/Development/home-manager";

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
