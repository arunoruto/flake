{
  lib,
  config,
  ...
}: {
  imports = [
    ./chrome.nix
    ./firefox.nix
    ./steam.nix
    ./packages.nix

    ./wayland.nix
  ];

  options.gui.enable = lib.mkEnableOption "Setup GUI Modules";

  config = lib.mkIf config.gui.enable {
    gui.packages.enable = lib.mkDefault true;
    wayland.enable = lib.mkDefault true;

    chrome.enable = lib.mkDefault true;
    firefox.enable = lib.mkDefault true;
    steam.enable = lib.mkDefault true;
  };
}
