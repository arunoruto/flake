{ lib, ... }:
{
  imports = [
    ./explo
    ./mpd.nix
    ./mopidy.nix
  ];
}
