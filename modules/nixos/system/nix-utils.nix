{
  config,
  pkgs,
  lib,
  ...
}:
let
  clean_nh_over_nix = true;
  primaryUserName = config.users.primaryUser;
in
{
  options = {
    nix-utils.enable = lib.mkEnableOption "Enable nix-utils";
  };

  config = lib.mkIf config.nix-utils.enable {
    environment = {
      systemPackages =
        with pkgs;
        (
          [
            nix-tree
            nix-output-monitor
            nvd
          ]
          ++ (lib.optionals (!(lib.elem "headless" config.system.tags)) [ nixpkgs-manual ])
        );
      sessionVariables.NH_FLAKE = "/home/${primaryUserName}/.config/flake";
    };

    services = {
      angrr.enable = true;
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
