{
  config,
  pkgs,
  lib,
  ...
}: {
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
      settings = {
        # build in a sandbox
        sandbox = true;
        # auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
      };
      optimise = {
        automatic = true;
        dates = ["04:00"];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
  };
}
