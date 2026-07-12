{
  inputs,
  config,
  pkgs,
  lib,
  # self,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    # A path literal (not "${inputs.self.outPath}/...") so the store copy is
    # content-addressed on secrets.yaml alone: unrelated repo changes no
    # longer rebuild every home configuration.
    defaultSopsFile = ../../../secrets/secrets.yaml;
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
      "ssh_keys/${config.user}".path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      # "ssh_keys/giyu".path = "${config.home.homeDirectory}/.ssh/id_giyu";
      # "ssh_keys/tengen".path = "${config.home.homeDirectory}/.ssh/id_tengen";
      # "ssh_keys/kanae".path = "${config.home.homeDirectory}/.ssh/id_kanae";
      "tokens/copilot" = { };
      "tokens/cachix" = { };
    };
  };

  # Fix launchd PATH issue on Darwin
  # The sops-nix service needs getconf in PATH to determine DARWIN_USER_TEMP_DIR
  launchd.agents.sops-nix = lib.mkIf isDarwin {
    enable = true;
    config = {
      EnvironmentVariables = {
        PATH = lib.mkForce "/usr/bin:/bin:/usr/sbin:/sbin";
      };
    };
  };

  home.packages = with pkgs; [
    age
    sops
    ssh-to-age
    ssh-to-pgp
  ];
}
