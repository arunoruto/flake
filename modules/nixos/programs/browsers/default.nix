{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./firefox.nix
  ];

  options.browsers.enable = lib.mkEnableOption "Enable browsers system-wide";

  config = lib.mkIf config.browsers.enable {
    # chrome.enable = lib.mkDefault true;
    programs.firefox.enable = lib.mkDefault false;
    # vivaldi.enable = lib.mkDefault false;

    # environment.systemPackages = [
    #   inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    # ];
  };
}
