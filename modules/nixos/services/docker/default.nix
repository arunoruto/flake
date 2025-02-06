{ config, lib, ... }:
{
  options.services.docker.enable = lib.mkEnableOption "Enable docker config";
  config = lib.mkIf config.services.docker.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
    };
    hardware.nvidia-container-toolkit.enable = config.hosts.nvidia.enable;
  };
}
