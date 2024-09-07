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

    ./input.nix
    ./theming.nix
  ];

  options.pc.enable = lib.mkEnableOption "PC config";

  config = lib.mkIf config.pc.enable {
    desktop.enable = lib.mkDefault true;
    documents.enable = lib.mkDefault true;
  };
}
