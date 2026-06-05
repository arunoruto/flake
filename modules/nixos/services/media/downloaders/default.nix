{ lib, ... }:
{
  imports = [
    ./arr
    ./qbittorrent.nix
    ./sabnzbd.nix
    ./soulsync
  ];
}
