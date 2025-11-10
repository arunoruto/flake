{ config, lib, ... }:
{
  config = lib.mkIf config.virtualisation.docker.enable {
    virtualisation.docker = {
      enableOnBoot = true;
    };
    hardware.nvidia-container-toolkit.enable = config.hosts.nvidia.enable;
  };
}
