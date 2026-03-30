{ config, lib, ... }:
{
  imports = [
    ./sound.nix
  ];

  config = lib.mkMerge [
    (lib.mkIf (lib.elem "desktop" config.system.tags) {
      services.pipewire.enable = lib.mkDefault true;
    })
    (lib.mkIf (!(lib.elem "desktop" config.system.tags)) {
      services.pipewire.enable = lib.mkForce false;
    })
  ];
}
