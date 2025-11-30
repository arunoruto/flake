{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.virtualisation.incus.enable {
    virtualisation = {
      libvirtd.enable = true;
      incus = {
        package = pkgs.incus;
        ui.enable = true;
        preseed = {
          networks = [
            {
              name = "incusbr0";
              type = "bridge";
              config = {
                "ipv4.address" = "10.0.100.1/24";
                "ipv4.nat" = "true";
              };
            }
          ];
          storage_pools = [
            {
              name = "zfs-incus";
              driver = "zfs";
              config = {
                source = "flash/incus";
              };
            }
          ];
        };
      };
    };

    networking = {
      nftables.enable = true;
      # interfaces.br0 = {
      #   useDHCP = true;
      # };
    };
  };
}
