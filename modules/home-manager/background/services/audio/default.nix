{ lib, ... }:
{
  imports = [
    ./mopidy.nix
  ];

  mopidy.enable = lib.mkDefault false;
  # mpd.enable = lib.mkDefault false;
}
