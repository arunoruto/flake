{
  config,
  lib,
  username,
  ...
}:
let
  pubKeys = lib.filesystem.listFilesRecursive (lib.path.append ../../../. "homes/${username}/keys");
in

{
  options = {
    ssh.enable = lib.mkEnableOption "Enable SSH and configure it";
  };

  config = lib.mkIf config.ssh.enable {
    services.openssh = {
      enable = true;
      hostKeys = [
        {
          # comment = "hi";
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    users.users.${username}.openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (
      key: builtins.readFile key
    );
  };
}
