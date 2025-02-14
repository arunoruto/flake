{ config, pkgs, ... }:
{
  imports = [
    # ./dns.nix
  ];
  #networking.hostName = "nixos"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking = {
    # Enable networking
    networkmanager = {
      enable = true;
      wifi.powersave = config.hosts.laptop.enable;
    };
    firewall = {
      # Disable the firewall altogether.
      # networking.firewall.enable = false;
      enable = true;
      # allow certain ports
      allowedTCPPorts = [
        1313 # hugo
        3390 # RDP
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    bind
  ];
}
