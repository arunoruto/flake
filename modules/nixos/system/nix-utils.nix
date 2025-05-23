{
  config,
  pkgs,
  lib,
  ...
}:
let
  clean_nh_over_nix = true;
  username = config.username;
in
{
  options = {
    nix-utils.enable = lib.mkEnableOption "Enable nix-utils";
  };

  config = lib.mkIf config.nix-utils.enable {
    environment = {
      systemPackages = with pkgs; [
        nix-tree
        nix-output-monitor
        nvd

        # nixpkgs-manual
      ];
      sessionVariables.NH_FLAKE = "/home/${username}/.config/flake";
    };

    programs.nh = {
      enable = true;
      package = pkgs.unstable.nh;
      clean = {
        enable = clean_nh_over_nix;
        extraArgs = "--keep-since 4d --keep 3";
      };
      # flake = ../../../.;
      # flake = "~/.config/flake";
    };

    # Auto clean system
    nix = {
      # package = pkgs.unstable.nix;
      settings = {
        sandbox = true;
        download-buffer-size = 134217728;
        warn-dirty = false;
        accept-flake-config = true;
        trusted-users = [
          "root"
          "@wheel"
        ];
        extra-experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        # extra-substituters = [
        #   "https://nix-community.cachix.org"
        #   "https://helix.cachix.org"
        #   "https://wezterm.cachix.org"
        # ];
        # extra-trusted-public-keys = [
        #   "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        #   "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        #   "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
        # ];
      };
      # extraOptions = ''
      #   trusted-users = root ${username}
      # '';
      optimise = {
        automatic = true;
        dates = [ "04:00" ];
      };
      gc = {
        automatic = !clean_nh_over_nix;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
  };
}
