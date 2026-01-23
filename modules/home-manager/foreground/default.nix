{
  lib,
  config,
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

  config = lib.mkIf config.foreground.enable {
    avatar.enable = lib.mkDefault true;
    desktop.enable = lib.mkDefault true;
    documents.enable = lib.mkDefault true;
    pc.programs.enable = lib.mkDefault true;
    terminals = {
      enable = lib.mkDefault true;
      main = "ghostty";
    };

    programs = {
      autorandr.enable = lib.mkDefault true;
      eww.enable = lib.mkDefault true;
      waybar.enable = lib.mkDefault true;
    };
  };
}
