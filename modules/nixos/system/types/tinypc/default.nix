{
  lib,
  config,
  ...
}:
{
  options.hosts.tinypc.enable = lib.mkEnableOption "Sensible defaults for tiny/mini PCs";

  config = lib.mkIf config.hosts.tinypc.enable {
    display-manager.enable = false;
    desktop-environment.enable = false;
    programs.enable = false;

    latex.enable = false;
    programming.enable = false;
    upgrades.enable = true;
    stylix.enable = false;

    programs.nix-ld.enable = lib.mkForce false;
    services = {
      kanata.enable = lib.mkForce false;
      keyd.enable = lib.mkForce false;
    };
  };
}
