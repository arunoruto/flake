{
  pkgs,
  config,
  lib,
  ...
}:
let
  # monitorsXmlContent = builtins.readFile /home/mar/.config/monitors.xml;
  # monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
  # monitorsConfig = pkgs.writeText "gdm_monitors.xml" (builtins.readFile /home/${username}/.config/monitors.xml);
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" (builtins.readFile ./monitors.xml);
in
{
  boot.binfmt.emulatedSystems = [
    # "x86_64-linux"
    "aarch64-linux"
    # "x86_64-darwin"
    # "aarch64-darwin"
  ];
  colmena.deployment = {
    buildOnTarget = true;
    targetHost = "madara.king-little.ts.net";

  };
  # nixpkgs.config.cudaSupport = true;
  ai.enable = true;
  printing.enable = true;
  scanning.enable = true;
  system.tags = [
    "workstation"
    "development"
  ];
  hosts = {
    nvidia.enable = true;
  };
  hardware = {
    custom = {
      keyboard.enable = true;
      mouse.enable = true;
    };
    nvidia = {
      nvidiaSettings = false;
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };
  yubikey.signing = "sanemi";
  runners.YASF.enable = true;
  nfs.enable = true;

  virtualisation.docker.enable = true;
  services = {
    harmonia = {
      enable = true;
      openFirewall = true;
    };
    # beszel-agent = {
    beszel.agent = {
      enable = true;
      package = pkgs.unstable.beszel;
      environment = {
        # LOG_LEVEL = "debug";
        LOG_LEVEL = "info";
        GPU = "true";
        KEY_FILE = config.sops.secrets."tokens/beszel-marvin".path;
        EXTRA_FILESYSTEMS = lib.strings.concatStringsSep "," [
          "nvme0n1p1"
          # "sda2"
        ];
      };
      # extraFilesystems = [
      #   "nvme0n1p1"
      #   # "sda2"
      # ];
      # extraPath = [ (lib.getBin config.boot.kernelPackages.nvidiaPackages.stable) ];
    };
    xrdp = {
      # enable = true;
      # defaultWindowManager = "gnome-remote-desktop";
      defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
      openFirewall = true;
    };
  };

  sops.secrets."tokens/beszel-marvin" = {
    mode = "0444";
    # owner = config.users.users.${gh-user}.name;
    # inherit (config.users.users.${gh-user}) group;
  };

  # hardware = {
  #   # Make logitech devices work easier
  #   logitech.wireless = {
  #     enable = true;
  #     enableGraphical = true;
  #   };

  #   # Tweaks for keychron
  #   bluetooth = {
  #     enable = true;
  #     settings = {
  #       General = {
  #         FastConnect = true;
  #         Experimental = true;
  #       };
  #       Policy = {
  #         ReconnectAttempts = 7;
  #         ReconnectIntervals = "1, 2, 3";
  #       };
  #     };
  #   };

  # };

  systemd = {
    # tmpfiles.rules = [
    #   "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
    # ];
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
  environment.systemPackages = with pkgs; [
    signal-desktop
  ];
}
