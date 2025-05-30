{ config, lib, ... }:
{
  config = lib.mkIf config.services.cloudflared.enable {
    boot.kernel.sysctl = {
      "net.core.wmem_max" = 7500000;
      "net.core.rmem_max" = 7500000;
    };
  };
}
