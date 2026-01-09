{ pkgs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    (with pkgs; [
      clinfo
      ffmpeg
      file
      git
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
      vim
      wget
    ])
    ++ (with pkgs.unstable; [
      # ventoy
      zenmap
    ]);
}
