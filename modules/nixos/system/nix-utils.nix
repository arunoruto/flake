{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  options = {
    nix-utils.enable = lib.mkEnableOption "Enable nix-utils";
  };

  config = lib.mkIf config.nix-utils.enable {
    environment.systemPackages = with pkgs; [
      unstable.nh
      nix-tree
      nix-output-monitor
      nvd
    ];

    # Auto clean system
    nix = {
      # package = pkgs.unstable.nix;
      settings = {
        sandbox = true;
        # auto-optimise-store = true;
        warn-dirty = false;
        accept-flake-config = true;
        extra-experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        extra-substituters = [
          "https://helix.cachix.org"
          "https://wezterm.cachix.org"
        ];
        extra-trusted-public-keys = [
          "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
          "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
        ];
      };
      extraOptions = ''
        trusted-users = root ${username}
      '';
      optimise = {
        automatic = true;
        dates = [ "04:00" ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
  };
}
