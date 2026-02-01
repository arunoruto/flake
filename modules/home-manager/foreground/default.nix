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

      programs = {
        autorandr.enable = lib.mkDefault default;
        eww.enable = lib.mkDefault default;
        waybar.enable = lib.mkDefault default;
      };
    };
}
