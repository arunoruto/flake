{
  config,
  lib,
  ...
}:
let
  primaryUserName = config.users.primaryUser;
  pubKeys = lib.filesystem.listFilesRecursive (
    lib.path.append ../../../. "homes/${primaryUserName}/keys"
  );
in

{
  config = lib.mkIf config.services.openssh.enable {
    services.openssh = {
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

    users.users = {
      ${primaryUserName}.openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (
        key: builtins.readFile key
      );
      root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVG8SSbWy37rel+Yhz9rjpNscmO1+Br57beNzWRdaQk"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdbD+VJ30cDQ+SLFWnyLPII+T/ngTdBHFyXVbfgX1BH"
      ];
    };

  };
}
