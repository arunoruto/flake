{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.reference-manager.enable = lib.mkEnableOption "Reference manager(s)";

  config = lib.mkIf config.programs.reference-manager.enable {
    environment.systemPackages = with pkgs; [
      # jabref
      paperlib
    ];
  };

}
