{ config, lib, ... }:
{
  config = lib.mkIf config.virtualisation.incus.enable {
    virtualisation = {
      incus.ui.enable = true;
      libvirtd.enable = true;
    };

    networking = {
      nftables.enable = true;
    };
  };
}
