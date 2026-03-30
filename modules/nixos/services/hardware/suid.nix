{
  config,
  pkgs,
  lib,
  ...
}:
let
  gnomeEnabled = lib.attrByPath [ "services" "desktopManager" "gnome" "enable" ] false config;
  plasmaEnabled = lib.attrByPath [ "services" "desktopManager" "plasma6" "enable" ] false config;

  pinentryPackage =
    if plasmaEnabled then
      pkgs.pinentry-qt
    else if gnomeEnabled then
      pkgs.pinentry-gnome3
    else
      pkgs.pinentry-curses;
in
{
  options = {
    suid.enable = lib.mkEnableOption ''
      Some programs need SUID wrappers,
      can be configured further or are
      started in user sessions.
    '';
  };

  config = lib.mkIf config.suid.enable {
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = lib.mkForce pinentryPackage;
      enableSSHSupport = true;
    };
  };
}
