{ lib, ... }:
{
  imports = [
    ./immich.nix
    ./jellyfin.nix
    ./plex
  ];
}
