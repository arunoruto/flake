# PAM policy for hosts with a fingerprint reader, applied whenever fprintd is
# on -- nixos-facter turns it on from the hardware report, and nixos-hardware
# does so for the Framework profiles.
{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.fprintd.enable {
    security.pam.services = {
      # A fingerprint unlocks the session, but does not log in.
      login.fprintAuth = false;
      # With a key plugged in, offer the fingerprint before the yubikey.
      sudo.rules.auth.u2f.order = config.security.pam.services.sudo.rules.auth.fprintd.order + 10;
    };
  };
}
