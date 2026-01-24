{
  lib,
  pkgs,
  config,
  ...
}:
{
  # imports = [ "${inputs.nixpkgs-unstable.outPath}/nixos/modules/hardware/fw-fanctrl.nix" ];
  colmena.deployment.allowLocalDeployment = lib.mkDefault true;
  gaming.chess.enable = lib.mkDefault true;

  system.tags = [
    "laptop"
    "development"
    "gaming"
  ];
  hosts = {
    amd.enable = true;
  };
  tpm.enable = false;

  # services = {
  #   auto-cpufreq.enable = true;
  #   power-profiles-daemon.enable = false;
  #   tlp.enable = false;
  # };

  # Fix 6GHz problem
  # https://community.frame.work/t/responded-amd-rz616-wifi-card-doesnt-work-with-6ghz-on-kernel-6-7/43226
  boot = {
    extraModprobeConfig = ''
      options mt7921_common disable_clc=1
    '';
    blacklistedKernelModules = [ "hid_sensor_hub" ];
  };

  programs = {
    distrobox.enable = true;
    matlab = {
      enable = true;
      release = "R2025a";
      licenseFile = config.sops.secrets."config/matlab".path;
    };
    niri.enable = true;
  };

  virtualisation = {
    # docker.enable = true;
  };

  hardware = {
    fw-fanctrl = {
      enable = true;
      package = pkgs.unstable.fw-fanctrl;
      # package = pkgs.unstable.fw-fanctrl.overrideAttrs (
      #   final: prev: {
      #     patches = (prev.patches or [ ]) ++ [ ./fw-fanctrl.patch ];
      #   }
      # );
    };
    # framework.enableKmod = false;
  };

  networking = {
    enableIPv6 = false;
    # wireless.iwd = {
    #   enable = true;
    # };
  };
  # environment.systemPackages = with pkgs; [ impala ];
  # networking.networkmanager.wifi.backend = "iwd";
  #
  sops.secrets."config/matlab".mode = "0444";
}
