{
  lib,
  config,
  ...
}: {
  imports = [
    ./firefox.nix
    ./steam.nix
    ./chrome.nix

    ./wayland.nix
  ];

  options.gui.enable = lib.mkEnableOption "Setup GUI Modules";

  config = lib.mkIf config.gui.enable {
    wayland.enable = lib.mkDefault true;

    chrome.enable = lib.mkDefault true;
    firefox.enable = lib.mkDefault true;
    steam.enable = lib.mkDefault true;
  };
}
