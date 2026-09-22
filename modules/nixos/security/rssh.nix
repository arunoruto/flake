# pam_rssh for sudo: authenticate against the keys the calling user's SSH
# agent holds, which pam_ssh_agent_auth cannot do for yubikey-backed keys.
# https://github.com/jbeverly/pam_ssh_agent_auth/issues/23
# https://github.com/z4yx/pam_rssh
#
# Off by default: a host opts in with `security.pam.rssh.enable = true`, and
# sudo then takes an agent key instead of a password. The old `rssh.enable`
# defaulted this on for every server without a yubikey, but it never took
# effect -- nixpkgs owns the `rssh` PAM rule and its `enable`, so the rule
# this flake declared stayed disabled and sudo kept asking for a password.
{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.security.pam.rssh.enable {
    security.pam = {
      rssh.settings.authorized_keys_command = pkgs.writeShellScript "get-authorized-keys" ''
        cat "/etc/ssh/authorized_keys.d/$1"
      '';

      services.sudo.rssh = true;
    };
  };
}
