{
  config,
  pkgs,
  lib,
  ...
}:
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
      pinentryPackage = lib.mkForce pkgs.pinentry-gnome3;
      enableSSHSupport = true;
    };
  };
}
