# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./devices/_pick.nix
    ./network.nix
    # ./systemd.nix
    ./services.nix
    ./environment.nix
    ./security.nix
    ./pr.nix
    ./dm/sway.nix
    ./dm/hyprland.nix
  ];

  # Bootloader.
  boot = {
    loader = {
      timeout = 0; # Hit F10 for a list of generations
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    #boot.plymouth = {
    #  enable = true;
    #  #theme = "catppuccin-macchiato";
    #  #themePackages = with pkgs; [ catppuccin-plymouth ];
    #};
    kernel.sysctl = {
      # https://github.com/tailscale/tailscale/issues/3310#issuecomment-1722601407
      "net.ipv4.conf.eth0.rp_filter" = 2;
    };
  };

  # Set your time zone.
  #time.timeZone = "Europe/Berlin";
  # allow TZ to be set by desktop user
  time.timeZone = lib.mkForce null;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # Auto updates
  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-${config.system.stateVersion}";
  };

  # Auto clean system
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
