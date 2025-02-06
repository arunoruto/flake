{
  pkgs,
  config,
  # lib,
  ...
}:
let
  # monitorsXmlContent = builtins.readFile /home/mar/.config/monitors.xml;
  # monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
  # monitorsConfig = pkgs.writeText "gdm_monitors.xml" (builtins.readFile /home/${username}/.config/monitors.xml);
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" (builtins.readFile ./monitors.xml);
in
{
  # nixpkgs.config.cudaSupport = true;
  ai.enable = true;
  printing.enable = true;
  scanning.enable = true;
  hosts = {
    workstation.enable = true;
    nvidia.enable = true;
  };
  hardware.nvidia = {
    nvidiaSettings = false;
    # package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
  yubikey.signing = "sanemi";
  runners.YASF.enable = true;
  nfs.enable = true;

  services = {
    docker.enable = true;
    beszel-agent = {
      enable = true;
      package = pkgs.unstable.beszel;
      gpu = true;
      keyFile = config.sops.secrets."tokens/beszel-marvin".path;
      extraFilesystems = [
        "nvme0n1p1"
        "sda2"
      ];
      logLevel = "debug";
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

  # systemd = {
  #   tmpfiles.rules = [
  #     "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
  #   ];
  # };
}
