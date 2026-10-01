# Facter-only host: no hardware-configuration.nix. Kernel modules, microcode,
# DHCP interfaces and the host platform all come from ./facter.json (loaded
# automatically by systems/default.nix); the filesystems come from ./disk.nix.
{ config, ... }:
{
  imports = [ ./disk.nix ];

  users.primaryUser = "mirza";

  system.tags = [ "server" ];

  colmena.deployment = {
    targetHost = config.networking.hostName;
  };
  hosts.intel.enable = true;
}
