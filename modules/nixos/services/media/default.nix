{ config, lib, ... }:
{
  imports = [
    ./sound.nix
  ];

  services.pipewire.enable = lib.mkDefault (!(lib.elem "tinypc" config.system.tags));
}
