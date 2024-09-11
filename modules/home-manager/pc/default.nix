{
  lib,
  config,
  ...
}: {
  imports = [
    ./desktop
    ./documents
    ./gui
    ./network
    ./terminal

    ./avatar.nix
    ./input.nix
    ./theming.nix
  ];

  options.pc.enable = lib.mkEnableOption "PC config";

  config = lib.mkIf config.pc.enable {
    avatar.enable = lib.mkDefault true;
    desktop.enable = lib.mkDefault true;
    documents.enable = lib.mkDefault true;
    gui.enable = lib.mkDefault true;
    terminals.enable = lib.mkDefault true;
  };
}
