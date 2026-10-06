{
  inputs,
  config,
  lib,
  ...
}:
let
  primaryUserName = config.users.primaryUser;
  user-conf = config.users.users.${primaryUserName};
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.secrets.enable = lib.mkEnableOption "Enable secrets managements using SOPS";

  config = lib.mkIf config.secrets.enable {
    sops = {
      # A path literal (not "${inputs.self.outPath}/...") so the store copy is
      # content-addressed on secrets.yaml alone: unrelated repo changes no
      # longer rebuild every host's system derivation.
      defaultSopsFile = ../../../secrets/secrets.yaml;
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
        "ssh_keys/${user-conf.name}" = {
          owner = user-conf.name;
          inherit (user-conf) group;
          path = "${user-conf.home}/.ssh/id_ed25519";
        };
        "tokens/copilot" = { };
        "tokens/cachix" = { };
        "yubico/u2f_keys/${user-conf.name}" = {
          owner = user-conf.name;
          inherit (user-conf) group;
          path = "${user-conf.home}/.config/Yubico/u2f_keys";
        };
      };
    };

    # sops-nix creates missing parents of a secret's `path` as root. On a
    # freshly created user that leaves ~/.ssh and ~/.config root-owned and
    # home-manager's activation then fails to link into them. Create them as
    # the user first.
    system.activationScripts = {
      primaryUserSecretDirs = {
        deps = [ "users" ];
        text = ''
          install -d -o ${user-conf.name} -g ${user-conf.group} -m 700 ${user-conf.home}/.ssh
          install -d -o ${user-conf.name} -g ${user-conf.group} -m 755 \
            ${user-conf.home}/.config ${user-conf.home}/.config/Yubico
        '';
      };
      setupSecrets.deps = [ "primaryUserSecretDirs" ];
    };
  };
}
