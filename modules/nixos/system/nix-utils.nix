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
        # build in a sandbox
        sandbox = true;
        # auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        extra-experimental-features = [
          "pipe-operators"
        ];
        warn-dirty = false;
        extra-substituters = [ "https://helix.cachix.org" ];
        extra-trusted-public-keys = [ "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs=" ];
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
