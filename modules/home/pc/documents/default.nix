{
  lib,
  config,
  ...
}:
{
  # imports = [
  #   ./libreoffice.nix
  # ];

  options.documents.enable = lib.mkEnableOption "Enable document apps";

  config = lib.mkIf config.documents.enable {
    libreoffice.enable = lib.mkDefault true;
  };
}
