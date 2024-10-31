{
  inputs,
  config,
  lib,
  username,
  ...
}:
let
  user-conf = config.users.users.${username};
  secretspath = builtins.toString inputs.secrets;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.secrets.enable = lib.mkEnableOption "Enable secrets managements using SOPS";

  config = lib.mkIf config.secrets.enable {
    sops = {
      defaultSopsFile = "${secretspath}/secrets.yaml";
      validateSopsFiles = false;

      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        keyFile = "/var/lib/sops-nix/keys.txt";
        generateKey = true;
      };

      secrets = {
        # "private_keys/mirza@zangetsu" = {
        #   path = config.home.homeDirectory + "/.ssh/sops_key";
        # };
        "tokens/copilot" = { };
        "tokens/cachix" = { };
        "yubico/u2f_keys" = {
          owner = user-conf.name;
          inherit (user-conf) group;
          path = "${user-conf.home}/.config/yubico/u2f_keys";
        };
      };
    };
  };
}