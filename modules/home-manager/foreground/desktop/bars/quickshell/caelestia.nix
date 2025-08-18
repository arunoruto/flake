{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.quickshell.caelestia = {
    enable = lib.mkEnableOption "Caelestia";
  };

  config =
    let
      cfg = config.programs.quickshell.caelestia;
    in
    lib.mkIf cfg.enable {
      home.packages =
        (with pkgs; [
          material-symbols
          nerd-fonts.jetbrains-mono
          ibm-plex
          cava
          bluez
          ddcutil
          brightnessctl
          imagemagickBig
        ])
        ++ (with pkgs.pythonPackages; [
          aubio
          pyaudio
          numpy
        ]);
    };
}
