{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Get username from config
  inherit (config) username;

  # Get shell from home-manager config
  shell = config.home-manager.users.${username}.shell.main or "bash";
in
{
  imports = [
    ./mirza.nix
    ./mar.nix
  ];

  options.users.users = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options.isAdmin = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable admin privileges for this user (wheel, docker, libvirtd, etc.)";
        };
      }
    );
  };

  config = {
    # SOPS secret for the user
    sops.secrets."passwords/${username}".neededForUsers = true;

    # Base user configuration (applied to ALL users)
    users.users.${username} = {
      isNormalUser = true;
      group = "users";
      shell = config.home-manager.users.${username}.programs.${shell}.package;
      description = "${username}";
      extraGroups = [
        "dialout"
        "networkmanager"
        "scanner"
        "lp"
        "pipewire"
        "audio"
        "video"
        "render"
        "input"
        "uinput"
        "tss" # tss group has access to TPM devices
      ];
    };

    # Enable fish
    programs.fish.enable = true;

    # Environment configuration
    environment = {
      shells = [ config.users.users.${username}.shell ];
      pathsToLink =
        lib.optionals config.home-manager.users.${username}.programs.zsh.enable [
          "/share/zsh"
        ]
        ++ lib.optionals config.home-manager.users.${username}.programs.fish.enable [
          "/share/fish"
        ];
    };

    # Accounts service configuration (if .face file exists)
    systemd.tmpfiles.rules = lib.optionals (config.home-manager.users.${username}.home.file ? ".face") (
      let
        account-service = pkgs.writeTextFile {
          name = "accounts-service-config-${username}";
          text = lib.generators.toINI { } {
            User = {
              Session = "gnome";
              Icon = "/var/lib/AccountsService/icons/${username}";
              SystemAccount = "false";
            };
          };
        };
      in
      [
        ''C "/var/lib/AccountsService/users/${username}" 0600 root root - ${account-service}''
        ''d  "/var/lib/AccountsService/icons" 0755 root root -''
        ''L+ "/var/lib/AccountsService/icons/${username}" - - - - ${
          config.home-manager.users.${username}.home.file.".face".source
        }''
      ]
    );
  };
}
