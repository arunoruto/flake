{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Get the primary user name - now required, no fallback
  primaryUserName = config.users.primaryUser;

  # Get shell from home-manager config for primary user
  shell = config.home-manager.users.${primaryUserName}.shell.main or "bash";
in
{
  imports = [
    ./mirza.nix
    ./mar.nix
  ];

  options = {
    # Primary user option - REQUIRED, must be set in system configuration
    users.primaryUser = lib.mkOption {
      type = lib.types.str;
      description = "Name of the primary user for this system (receives home-manager, SSH keys, theming, etc.). This option is REQUIRED and must be set in your system configuration.";
    };

    # Extend users.users type to add isAdmin option
    users.users = lib.mkOption {
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
  };

  config = {
    # Validation assertions
    assertions = [
      {
        assertion = config.users.primaryUser != "";
        message = "users.primaryUser must be set to a non-empty string! Please set users.primaryUser = \"<username>\" in your system configuration.";
      }
      {
        assertion = config.users.users ? ${primaryUserName};
        message = "users.primaryUser is set to '${primaryUserName}' but no such user exists in users.users! Please ensure the user is defined.";
      }
    ];

    # SOPS secret for the primary user
    sops.secrets."passwords/${primaryUserName}".neededForUsers = true;

    # Base user configuration for the primary user
    users.users.${primaryUserName} = {
      isNormalUser = true;
      group = "users";
      shell = config.home-manager.users.${primaryUserName}.programs.${shell}.package;
      description = "${primaryUserName}";
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
      shells = [ config.users.users.${primaryUserName}.shell ];
      pathsToLink =
        lib.optionals config.home-manager.users.${primaryUserName}.programs.zsh.enable [
          "/share/zsh"
        ]
        ++ lib.optionals config.home-manager.users.${primaryUserName}.programs.fish.enable [
          "/share/fish"
        ];
    };

    # Configure home-manager for primary user by default
    homes.users = lib.mkDefault [ primaryUserName ];

    # Accounts service configuration (if .face file exists)
    systemd.tmpfiles.rules =
      lib.optionals (config.home-manager.users.${primaryUserName}.home.file ? ".face")
        (
          let
            account-service = pkgs.writeTextFile {
              name = "accounts-service-config-${primaryUserName}";
              text = lib.generators.toINI { } {
                User = {
                  Session = "gnome";
                  Icon = "/var/lib/AccountsService/icons/${primaryUserName}";
                  SystemAccount = "false";
                };
              };
            };
          in
          [
            ''C "/var/lib/AccountsService/users/${primaryUserName}" 0600 root root - ${account-service}''
            ''d  "/var/lib/AccountsService/icons" 0755 root root -''
            ''L+ "/var/lib/AccountsService/icons/${primaryUserName}" - - - - ${
              config.home-manager.users.${primaryUserName}.home.file.".face".source
            }''
          ]
        );
  };
}
