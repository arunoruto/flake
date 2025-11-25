{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.avahi.enable {
    # Resolve .local
    services.avahi = {
      ipv6 = false;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
      nssmdns4 = true;
      openFirewall = true;
    };

    # this is what avahi.nssmdns does, but mdns4 (IPv4) instead of mdns (dual-stack)
    system.nssModules = pkgs.lib.optional true pkgs.nssmdns;
    system.nssDatabases.hosts = pkgs.lib.optionals true (
      pkgs.lib.mkMerge [
        (pkgs.lib.mkBefore [ "mdns4_minimal [NOTFOUND=return]" ]) # before resolve
        (pkgs.lib.mkAfter [ "mdns4" ]) # after dns
      ]
    );
  };
}
