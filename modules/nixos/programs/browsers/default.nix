{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # ./chrome.nix
    ./firefox.nix
    # ./vivaldi.nix
  ];

  options.browsers.enable = lib.mkEnableOption "Enable browsers system-wide";

  config = lib.mkIf config.browsers.enable {
    # chrome.enable = lib.mkDefault true;
    firefox.enable = lib.mkDefault false;
    # vivaldi.enable = lib.mkDefault false;

    # environment.systemPackages = [
    #   inputs.zen-browser.packages.${pkgs.system}.default
    # ];
  };
}
