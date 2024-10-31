{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.fingerprint.enable = lib.mkEnableOption "Enable fingerprint scanner support";

  config = lib.mkIf config.fingerprint.enable {
    # Enable fingerprint support with goodix (framework)
    # services.fprintd = {
    #   enable = true;
    #   # The following should work, but it does not...
    #   # package = pkgs.fprintd-tod;
    #   # tod = {
    #   #   enable = true;
    #   #   driver = pkgs.libfprint-2-tod1-goodix;
    #   # };
    # };

    # systemd.services.fprintd = {
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig.Type = "simple";
    # };

    # security.pam.services = {
    #   login = {
    #     # Enable fprintd for login, and it seems like for gnome and other stuff...
    #     fprintAuth = true;
    #   };
    #   # If a key is pluged in, prioritse the fprintd instead of a yubikey
    #   # sudo.rules.auth.fprintd.order = config.security.pam.services.sudo.rules.auth.u2f.order - 10;
    #   # sudo.rules.auth.u2f.order = config.security.pam.services.sudo.rules.auth.fprintd.order + 10;
    # };

    ## we need fwupd 1.9.7 to downgrade the fingerprint sensor firmware
    # services.fwupd.package =
    #   (import (builtins.fetchTarball {
    #       url = "https://github.com/NixOS/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
    #       sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
    #     }) {
    #       inherit (pkgs) system;
    #     })
    #   .fwupd;

    ## Legacy...
    # security = {
    #   # Security settings
    #   pam.services.login.fprintAuth = false;

    #   # Enable gnome keyring in lightdm
    #   #security.pam.services.lightdm.enableGnomeKeyring = true;

    #   # similarly to how other distributions handle the fingerprinting login
    #   pam.services.gdm-fingerprint = lib.mkIf config.services.fprintd.enable {
    #     text = ''
    #       auth       required                    pam_shells.so
    #       auth       requisite                   pam_nologin.so
    #       auth       requisite                   pam_faillock.so      preauth
    #       auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
    #       auth       optional                    pam_permit.so
    #       auth       required                    pam_env.so
    #       auth       [success=ok default=1]      ${pkgs.gnome.gdm}/lib/security/pam_gdm.so
    #       auth       optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so

    #       account    include                     login

    #       password   required                    pam_deny.so

    #       session    include                     login
    #       session    optional                    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
    #     '';
    #   };
    # };
  };
}
