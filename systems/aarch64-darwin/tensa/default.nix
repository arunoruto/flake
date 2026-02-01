{
  config,
  pkgs,
  lib,
  inputs,
  self,
  ...
}:
{
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    overlays = [
      self.overlays.unstable-packages
    ];
    config.allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    helix
    nh
  ];

  services.tailscale.enable = true;
  networking.hostName = "tensa";

  system = {
    primaryUser = "mirza";
    defaults = {
      dock = {
        autohide = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      nonUS.remapTilde = true;
      remapCapsLockToEscape = true;
      swapLeftCtrlAndFn = true;
      userKeyMapping = [
        (lib.mkIf config.system.keyboard.remapCapsLockToEscape {
          HIDKeyboardModifierMappingSrc = 30064771113;
          HIDKeyboardModifierMappingDst = 30064771129;
        })
      ];
    };
  };

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };

  users.users.mirza = {
    name = "mirza";
    home = "/Users/mirza";
  };

  home-manager = {
    verbose = true;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm.old";
    extraSpecialArgs = { inherit inputs; };
    users.mirza = {
      imports = [
        ../../homes/mirza
        self.homeModules.default
        inputs.stylix.homeModules.stylix
      ];
      options.user = lib.mkOption {
        type = lib.types.str;
        default = "mirza";
      };
      config = {
        home = {
          username = "mirza";
          homeDirectory = lib.mkForce "/Users/mirza";
        };
        stylix.targets.hyprland.enable = false;
        stylix.targets.hyprpaper.enable = false;
        stylix.targets.waybar.enable = false;
        programs.opencode.enable = true;
      };
    };
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "mirza";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    casks = [ "zoom" ];
  };

  system.stateVersion = 6;

  nix = {
    enable = false;
    settings = {
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
  };
}
