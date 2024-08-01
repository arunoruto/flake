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

    age.keyFile = config.home.homeDirectory + "/.config/sops/age/keys.txt";

    secrets = {
      "private_keys/mirza@zangetsu" = {
        path = config.home.homeDirectory + "/.ssh/sops_key";
      };
      "tokens/copilot" = {};
    };
  };

  home.packages = with pkgs; [
    age
    sops
    ssh-to-age
  ];
}
