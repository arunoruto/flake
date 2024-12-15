{
  lib,
  config,
  ...
}:
{
  imports = [
    ./desktop
    ./documents
    ./programs
    ./terminal

    ./avatar.nix
    ./input.nix
  ];

  options.pc.enable = lib.mkEnableOption "PC config";

  config = lib.mkIf config.pc.enable {
    avatar.enable = lib.mkDefault true;
    desktop.enable = lib.mkDefault true;
    documents.enable = lib.mkDefault true;
    pc.programs.enable = lib.mkDefault true;
    terminals.enable = lib.mkDefault true;

    programs = {
      autorandr.enable = lib.mkDefault true;
      eww.enable = lib.mkDefault true;
      waybar.enable = lib.mkDefault true;
    };
  };
}
