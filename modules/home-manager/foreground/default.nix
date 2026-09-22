{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./audio
    ./colors
    ./desktop
    ./documents
    ./programs
    ./terminal

    ./avatar.nix
    ./input.nix
  ];

  options.foreground.enable = lib.mkEnableOption "PC config";

  config =
    let
      default = pkgs.stdenv.hostPlatform.isLinux;
    in
    lib.mkIf config.foreground.enable {
      avatar.enable = lib.mkDefault default;
      desktop.enable = lib.mkDefault default;
      documents.enable = lib.mkDefault default;
      pc.programs.enable = lib.mkDefault default;
      terminals = {
        enable = lib.mkDefault true;
        main = "ghostty";
      };
      # Bars are enabled per compositor through `bars.*` (desktop/bars/), not
      # here: GNOME draws its own panel, so installing them on every Linux GUI
      # host only carried binaries with nothing to run them.
    };
}
