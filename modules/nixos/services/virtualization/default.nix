{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./docker

    ./incus.nix
    ./libvirt.nix
  ];

  # config = lib.mkIf (with config.virtualisation; (incus.enable || libvirt.enable)) {
  config = lib.mkIf config.virtualisation.libvirtd.enable {
    networking = {
      # defaultGateway = "10.0.0.1";
      # bridges.br0.interfaces = [ ];
      interfaces.br0 = {
        useDHCP = true;
        # ipv4.addresses = [
        #   {
        #     "address" = "10.0.0.2";
        #     "prefixLength" = 24;
        #   }
        # ];
      };
    };

    environment.systemPackages = with pkgs; [ bridge-utils ];
  };
}
