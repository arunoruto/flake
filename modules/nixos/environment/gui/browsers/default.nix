{
  lib,
  config,
  ...
}: {
  imports = [
    ./chrome.nix
    ./firefox.nix
    ./vivaldi.nix
  ];

  options.browsers.enable = lib.mkEnableOption "Enable browsers system-wide";

  config = lib.mkIf config.browsers.enable {
    chrome.enable = lib.mkDefault true;
    firefox.enable = lib.mkDefault true;
    vivaldi.enable = lib.mkDefault true;
  };
}
