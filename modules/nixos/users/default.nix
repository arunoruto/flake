{
  config,
  lib,
  ...
}:
let
  # Get the primary user name - now required, no fallback
  primaryUserName = config.users.primaryUser;

  # Get shell from home-manager config for primary user
  shell = config.home-manager.users.${primaryUserName}.shell.main or "bash";

  # Auto-import sibling user modules (mirza.nix, mar.nix, avatar.nix, ...).
  # mk-user.nix is a helper (takes a username), not a module, so it is excluded.
  siblingModules = map (name: ./. + "/${name}") (
    lib.attrNames (
      lib.filterAttrs (name: type: type == "regular" && name != "default.nix" && name != "mk-user.nix") (
        builtins.readDir ./.
      )
    )
  );

  # Does secrets.yaml have a `passwords.<primaryUserName>` entry? sops-nix
  # fails activation outright if a declared secret's path doesn't exist in
  # the file, so the hashed-password wiring below only applies when it does.
  # Only the top-level *keys* of an ENC[]-valued sops file are cleartext, so
  # this scans the raw YAML text for the `passwords:` block specifically
  # (other sections, e.g. `ssh_keys:`, reuse the same usernames as keys).
  hasPasswordSecret =
    let
      lines = lib.splitString "\n" (builtins.readFile ../../../secrets/secrets.yaml);
      isTopLevelKey = line: line != "" && !(lib.hasPrefix " " line) && !(lib.hasPrefix "\t" line);
      step =
        acc: line:
        if acc.found then
          acc
        else if isTopLevelKey line then
          {
            inSection = line == "passwords:";
            found = false;
          }
        else if acc.inSection && lib.hasPrefix "    ${primaryUserName}:" line then
          {
            inherit (acc) inSection;
            found = true;
          }
        else
          acc;
    in
    (lib.foldl' step {
      inSection = false;
      found = false;
    } lines).found;
in
{
  imports = [
    ../../shared/users.nix
  ]
  ++ siblingModules;

  options = {
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

    # SOPS secret for the primary user's login password — only declared when
    # secrets.yaml actually has one, see hasPasswordSecret above.
    sops.secrets = lib.mkIf hasPasswordSecret {
      "passwords/${primaryUserName}".neededForUsers = true;
    };

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
    }
    // lib.optionalAttrs hasPasswordSecret {
      hashedPasswordFile = config.sops.secrets."passwords/${primaryUserName}".path;
    };

    # Enable fish
    programs.fish.enable = true;

    # Environment configuration
    environment = {
      shells = [ config.users.users.${primaryUserName}.shell ];
      pathsToLink = [
        "/share/xdg-desktop-portal"
        "/share/applications"
      ]
      ++ lib.optionals config.home-manager.users.${primaryUserName}.programs.zsh.enable [
        "/share/zsh"
      ]
      ++ lib.optionals config.home-manager.users.${primaryUserName}.programs.fish.enable [
        "/share/fish"
      ];
    };

    # Configure home-manager for primary user by default
    homes.users = lib.mkDefault [ primaryUserName ];
  };
}
