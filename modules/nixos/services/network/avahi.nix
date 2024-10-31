{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    local-resolv.enable = lib.mkEnableOption "Enable local resolution";
  };

  config = lib.mkIf config.local-resolv.enable {
    # Resolve .local
    services.avahi = {
      enable = true;
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
