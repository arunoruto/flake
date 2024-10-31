{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.rssh.enable = lib.mkEnableOption "Use RSSH, since sshAgentAuth does not support YubiKey";
  # yubikey login / sudo
  # NOTE: We use rssh because sshAgentAuth is old and doesn't support yubikey:
  # https://github.com/jbeverly/pam_ssh_agent_auth/issues/23
  # https://github.com/z4yx/pam_rssh
  config = lib.mkIf config.rssh.enable {
    security.pam.services.sudo =
      { config, ... }:
      {
        rules.auth.rssh = {
          order = config.rules.auth.ssh_agent_auth.order - 1;
          control = "sufficient";
          modulePath = "${pkgs.pam_rssh}/lib/libpam_rssh.so";
          settings.authorized_keys_command = pkgs.writeShellScript "get-authorized-keys" ''
            cat "/etc/ssh/authorized_keys.d/$1"
          '';
        };
      };
  };
}
