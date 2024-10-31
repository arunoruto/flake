{
  pkgs,
  lib,
  config,
  username,
  ...
}:
let
  homedir = if pkgs.stdenv.isLinux then "/home/${username}" else throw "Only setup for Linux!";
in
{
  options.yubikey.enable = lib.mkEnableOption "YubiKey specific settings";

  config = lib.mkIf config.yubikey.enable {
    environment.systemPackages = with pkgs; [
      yubioath-flutter
      yubikey-manager
      pam_u2f
    ];

    services = {
      pcscd.enable = true; # smartcard device
      udev.packages = [ pkgs.yubikey-personalization ];
      yubikey-agent.enable = true;
    };

    security.pam = lib.optionalAttrs pkgs.stdenv.isLinux {
      sshAgentAuth.enable = true;
      u2f = {
        enable = true;
        # settings = {
        cue = true; # Tells the user they need to press the button
        authFile = "${homedir}/.config/yubico/u2f_keys";
        # };
      };
      services = {
        login.u2fAuth = true;
        sudo = {
          u2fAuth = true;
          sshAgentAuth = true;
        };
      };
    };
  };
}
