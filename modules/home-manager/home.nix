{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) user;
in
{
  imports = [
    ./environment.nix
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
    homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${user}" else "/home/${user}";

    # Like system.stateVersion: an install-time fact, never bumped afterwards.
    # This is only the fallback for the oldest homes — a home first created on
    # a later release should set its own value.
    stateVersion = lib.mkDefault "23.05";
  };

}
