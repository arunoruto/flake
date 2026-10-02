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

  # Does secrets.yaml have a `passwords.<name>` entry? sops-nix fails
  # activation outright if a declared secret's path doesn't exist in the file,
  # so the hashed-password wiring below only applies when it does. Only the
  # top-level *keys* of an ENC[]-valued sops file are cleartext, so this scans
  # the raw YAML text for the `passwords:` block specifically (other sections,
  # e.g. `ssh_keys:`, reuse the same usernames as keys).
  hasPasswordSecret =
    name:
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
        else if acc.inSection && lib.hasPrefix "    ${name}:" line then
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

  primaryHasPassword = hasPasswordSecret primaryUserName;

  # root gets its own `passwords.root` when there is one, and falls back to
  # the primary user's password otherwise.
  rootPasswordSecret =
    if hasPasswordSecret "root" then
      "passwords/root"
    else if primaryHasPassword then
      "passwords/${primaryUserName}"
    else
      null;
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

    # SOPS secrets for the login passwords — only declared when secrets.yaml
    # actually has them, see hasPasswordSecret above.
    sops.secrets = lib.mkMerge [
      (lib.mkIf primaryHasPassword { "passwords/${primaryUserName}".neededForUsers = true; })
      (lib.mkIf (rootPasswordSecret != null) { ${rootPasswordSecret}.neededForUsers = true; })
    ];

    users = {
      # With the password in sops, the config is the source of truth for it.
      # Mutable users only apply a password when the account is first created,
      # so a host installed before its sops key was added would keep a locked
      # password forever. Imperatively set passwords (passwd) and users
      # (useradd) are reset/removed on activation from here on; a host that
      # needs them sets this back to true.
      mutableUsers = lib.mkDefault (!primaryHasPassword);

      users = {
        root = lib.mkIf (rootPasswordSecret != null) {
          hashedPasswordFile = config.sops.secrets.${rootPasswordSecret}.path;
        };

        # Base user configuration for the primary user
        ${primaryUserName} = {
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
        // lib.optionalAttrs primaryHasPassword {
          hashedPasswordFile = config.sops.secrets."passwords/${primaryUserName}".path;
        };
      };
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
