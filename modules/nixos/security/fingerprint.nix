{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.fingerprint.enable = lib.mkEnableOption "Enable fingerprint scanner support" // {
    default = config.facter.detected.fingerprint.enable;
  };

  config = lib.mkIf config.fingerprint.enable {
    # Enable fingerprint support with goodix (framework)
    services.fprintd = {
      enable = true;
      # The following should work, but it does not...
      # package = pkgs.fprintd-tod;
      # tod = {
      #   enable = true;
      #   driver = pkgs.libfprint-2-tod1-goodix;
      # };
    };

    # systemd.services.fprintd = {
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig.Type = "simple";
    # };

    security.pam.services = {
      login.fprintAuth = false;

      # If a key is pluged in, prioritse the fprintd instead of a yubikey
      # sudo.rules.auth.fprintd.order = config.security.pam.services.sudo.rules.auth.u2f.order - 10;
      sudo.rules.auth.u2f.order = config.security.pam.services.sudo.rules.auth.fprintd.order + 10;

      # Enable gnome keyring in lightdm
      #security.pam.services.lightdm.enableGnomeKeyring = true;

      ## https://github.com/NixOS/nixpkgs/issues/171136#issuecomment-1627779037
      # similarly to how other distributions handle the fingerprinting login
      # gdm-fingerprint.text = lib.mkIf config.services.fprintd.enable (
      #   ''
      #     auth       required                    pam_shells.so
      #     auth       requisite                   pam_nologin.so
      #     auth       requisite                   pam_faillock.so      preauth
      #     auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
      #     auth       required                    pam_env.so
      #   ''
      #   + lib.optionalString config.security.pam.services.login.enableGnomeKeyring ''
      #     auth       [success=ok default=1]      ${pkgs.gdm}/lib/security/pam_gdm.so
      #     auth       optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so
      #   ''
      #   + ''

      #     account    include                     login

      #     password   required                    pam_deny.so

      #     session    include                     login
      #   ''
      #   # + lib.optionalString config.security.pam.services.login.enableGnomeKeyring ''
      #   #   session    optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
      #   # ''
      # );
    };

    ## we need fwupd 1.9.7 to downgrade the fingerprint sensor firmware
    # services.fwupd.package =
    #   (import (builtins.fetchTarball {
    #       url = "https://github.com/NixOS/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
    #       sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
    #     }) {
    #       inherit (pkgs) system;
    #     })
    #   .fwupd;
  };
}
