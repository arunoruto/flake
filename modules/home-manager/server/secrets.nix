{
  inputs,
  config,
  pkgs,
  ...
}: let
  secretspath = builtins.toString inputs.secrets;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    # defaultSopsFile = "/home/mirza/Projects/secrets.nix/secrets.yaml";
    validateSopsFiles = false;

    age = {
      # sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = config.home.homeDirectory + "/.config/sops/age/keys.txt";
      # generateKey = true;
    };

    secrets = {
      "private_keys/mirza@zangetsu" = {
        path = config.home.homeDirectory + "/.ssh/sops_key";
      };
      "tokens/copilot" = {};
      "tokens/cachix" = {};
    };
  };

  home.packages = with pkgs; [
    age
    sops
    ssh-to-age
  ];
}
