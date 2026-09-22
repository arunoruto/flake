# The gnupg agent (with SSH support), using the pinentry that matches the
# desktop. Along with `programs.mtr` in ./default.nix this is the NixOS
# installer template's "some programs need SUID wrappers" block, which is
# where the old `suid.enable` name came from.
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
  programs.gnupg.agent = {
    enable = lib.mkDefault true;
    pinentryPackage = lib.mkForce pinentryPackage;
    enableSSHSupport = lib.mkDefault true;
  };
}
