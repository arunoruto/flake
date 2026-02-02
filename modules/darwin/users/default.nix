{
  config,
  lib,
  pkgs,
  ...
}:
let
  primaryUser = config.users.primaryUser;
  # Platform-specific fallback: bash for Linux, zsh for macOS
  defaultShell = if pkgs.stdenv.isDarwin then "zsh" else "bash";
  shell = config.home-manager.users.${primaryUser}.shell.main or defaultShell;
in
{
  options.users.primaryUser = lib.mkOption {
    type = lib.types.str;
    description = "Primary user for this system (works on both NixOS and Darwin)";
  };

  config = {
    # Validate shell selection
    assertions = [
      {
        assertion = builtins.elem shell [
          "bash"
          "fish"
          "zsh"
          "nushell"
        ];
        message = ''
          Invalid shell selection: "${shell}"

          shell.main must be one of: bash, fish, zsh, nushell

          Check your home-manager configuration in homes/${primaryUser}/default.nix
        '';
      }
    ];

    # Define the primary user with automatic shell from home-manager
    users.users.${primaryUser} = {
      name = primaryUser;
      home = "/Users/${primaryUser}";
      shell = config.home-manager.users.${primaryUser}.programs.${shell}.package;
    };

    # System primary user (for nix-darwin)
    system.primaryUser = primaryUser;

    # Enable system-level shell program
    # This ensures the shell is added to /etc/shells and completions are linked
    programs = {
      fish.enable = lib.mkIf (shell == "fish") true;
      zsh.enable = lib.mkIf (shell == "zsh") true;
      # Note: nushell doesn't have programs.nushell.enable on Darwin yet
    };

    # Add user's shell to environment.shells (required for /etc/shells)
    environment.shells = [ config.users.users.${primaryUser}.shell ];

    # Enable home-manager for all users with home configs
    homes.enable = lib.mkDefault true;

    # Configure home-manager for primary user by default
    homes.users = lib.mkDefault [ primaryUser ];
  };
}
