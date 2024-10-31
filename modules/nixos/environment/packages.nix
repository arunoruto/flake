{ pkgs, ... }:
{
  # imports = [
  #   ./chrome.nix
  # ];

  environment = {
    # Enable shells
    shells = with pkgs; [ zsh ];
    pathsToLink = [ "/share/zsh" ];

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      clinfo
      dig
      direnv
      ffmpeg
      file
      git
      htop
      imagemagickBig
      iperf
      killall
      nmap
      ntfs3g
      usbutils
      pciutils
      powertop
      tlrc
      traceroute
      unzip

      dust
      riffdiff
      # unstable.ventoy
      wget
    ];
  };
}
