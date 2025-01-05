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
  options.ssh.enable = lib.mkEnableOption "Enable personal SSH settings";

  config = lib.mkIf config.ssh.enable {
    programs.ssh = {
      enable = true;
      # Required for yubikey-agent
      addKeysToAgent = "yes";
      matchBlocks = {
        hublab = {
          host = "gitlab.com github.com";
          identitiesOnly = false;
          # identityFile = [
          #   "~/.ssh/id_sops"
          # ];
        };
        ultron-tail = {
          host = "ultron.tail";
          hostname = "ultron";
          user = "mar";
          # forwardX11 = "yes";
        };
        marvin = {
          host = "marvin";
          hostname = "marvin.king-little.ts.net";
          user = "mar";
          extraOptions.PubkeyAuthentication = "no";
        };
      };
    };

    home.file = { } // (publicKeyEntries pathToYubikeys) // (publicKeyEntries pathToUserKeys);
  };
}
