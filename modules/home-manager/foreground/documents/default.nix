{
  lib,
  config,
  ...
}:
{
  imports = [
    ./libreoffice.nix
    # ./onlyoffice.nix
  ];

  options.documents.enable = lib.mkEnableOption "Enable document apps";

  config = lib.mkIf config.documents.enable {
    programs = {
      libreoffice.enable = lib.mkDefault true;
      onlyoffice.enable = lib.mkDefault false;
    };
  };
}
