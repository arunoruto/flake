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
  ];

  options.foreground.enable = lib.mkEnableOption "PC config";

  config =
    let
      default = pkgs.stdenv.hostPlatform.isLinux;
    in
    lib.mkIf config.foreground.enable {
      # avatar.nix, documents/ and programs/ apply on Linux with this
      # option; they had switches of their own that nothing ever set.
      desktop.enable = lib.mkDefault default;
      terminals = {
        enable = lib.mkDefault true;
        main = "ghostty";
      };
      # Bars are opt-in through their own `programs.<name>.enable`
      # (desktop/bars/), not defaulted here: GNOME draws its own panel, so
      # installing them on every Linux GUI host only carried binaries with
      # nothing to run them.
    };
}
