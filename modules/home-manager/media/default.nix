{ lib, ... }:
{
  imports = [
    ./mopidy.nix
    # ./mpd.nix
  ];

  mopidy.enable = lib.mkDefault false;
  # mpd.enable = lib.mkDefault false;
}
