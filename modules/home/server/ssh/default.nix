{
  config,
  lib,
  ...
}:
let
  nix-home = "homes/x86_64-linux";
  pathToUserKeys = lib.path.append ../../../. "${nix-home}/${config.home.username}/keys";
  pathToYubikeys = lib.path.append ../../../. "${nix-home}/keys";
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
      extraConfig = ''
        SetEnv TERM=xterm-256color
      '';
      matchBlocks = {

        hublab = {
          host = "gitlab.com github.com";
          identitiesOnly = false;
          # identityFile = [
          #   "~/.ssh/id_sops"
          # ];
        };
        ultron = {
          host = "ultron";
          hostname = "ultron.king-little.ts.net";
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
