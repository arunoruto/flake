{
  config,
  lib,
  ...
}:
let
  pathToUserKeys = lib.path.append ../../../. "homes/${config.home.username}/keys";
  pathToYubikeys = lib.path.append ../../../. "homes/keys";
  keys =
    pathToKeys:
    lib.lists.forEach (builtins.attrNames (builtins.readDir pathToKeys)) (
      key: lib.substring 0 (lib.stringLength key - lib.stringLength ".pub") key
    );
  publicKeyEntries =
    pathToKeys:
    lib.attrsets.mergeAttrsList (
      lib.lists.map (key: {
        ".ssh/${key}.pub".source = "${pathToKeys}/${key}.pub";
      }) (keys pathToKeys)
    );
in
{
  config = lib.mkIf config.programs.ssh.enable {
    programs.ssh = {
      enableDefaultConfig = false;
      # Required for yubikey-agent
      extraConfig = ''
        SetEnv TERM=xterm-256color
      '';
      settings = {
        "*" = {
          addKeysToAgent = "yes";
        };

        hublab = {
          Host = "gitlab.com github.com";
          IdentitiesOnly = false;
          # identityFile = [
          #   "~/.ssh/id_sops"
          # ];
        };
        ultron = {
          Host = "ultron";
          HostName = "ultron.king-little.ts.net";
          User = "mar";
          # forwardX11 = "yes";
        };
        marvin = {
          Host = "marvin";
          HostName = "marvin.king-little.ts.net";
          User = "mar";
          PubkeyAuthentication = "no";
        };
      };
    };

    home.file =
      { }
      # // (publicKeyEntries pathToYubikeys)
      // (publicKeyEntries pathToUserKeys);
  };
}
