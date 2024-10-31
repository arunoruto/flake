{
  config,
  lib,
  ...
}:
let
  # pathToKeys = ./keys;
  pathToKeys = config.home.sessionVariables.FLAKE + "homes/mirza/keys";
  yubikeys = lib.lists.forEach (builtins.attrNames (builtins.readDir pathToKeys)) (
    key: lib.substring 0 (lib.stringLength key - lib.stringLength ".pub") key
  );
  yubikeyPublicKeyEntries = lib.attrsets.mergeAttrsList (
    lib.lists.map (key: {
      ".ssh/${key}.pub".source = "${pathToKeys}/${key}.pub";
    }) yubikeys
  );
in
{
  options.ssh.enable = lib.mkEnableOption "Enable personal SSH settings";

  config = lib.mkIf config.ssh.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        hublab = {
          host = "gitlab.com github.com";
          identitiesOnly = false;
          identityFile = [
            "~/.ssh/id_sops"
          ];
        };
        ultron-tail = {
          host = "ultron.tail";
          hostname = "ultron";
          user = "mar";
          # forwardX11 = "yes";
        };
      };
      extraConfig = ''
        # Required for yubikey-agent
        AddKeysToAgent yes
      '';
    };

    home.file = { } // yubikeyPublicKeyEntries;
  };
}
