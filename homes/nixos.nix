{
  config,
  lib,
  pkgs,
  inputs,
  self,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;

  mkUserConfig = username: {
    imports = [
      ./${username}
      self.homeModules.default
      # Note: stylix is imported at the system level (nixosModules.stylix or darwinModules.stylix)
      # which automatically configures home-manager, so we don't import it here
    ];
    options.user = lib.mkOption {
      type = lib.types.str;
      default = username;
    };
    config = {
      home = {
        inherit username;
        homeDirectory = lib.mkForce (if isDarwin then "/Users/${username}" else "/home/${username}");
      };
      # Linux-only Stylix targets are disabled on Darwin in
      # modules/home-manager/theming/darwin-targets.nix.
      programs.opencode.enable = lib.mkDefault true;
    };
  };
in
{
  options.homes = {
    enable = lib.mkEnableOption "Enable home-manager" // {
      default = true;
    };

    verbose = lib.mkEnableOption "Verbose home-manager output" // {
      default = true;
    };

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of usernames to configure with home-manager. Each username should have a matching directory in homes/. Defaults to primary user if empty.";
    };
  };

  config = lib.mkIf config.homes.enable {
    home-manager = {
      inherit (config.homes) verbose;
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm.old";
      extraSpecialArgs = { inherit inputs; };
      users = lib.genAttrs config.homes.users mkUserConfig;
    };
  };
}
