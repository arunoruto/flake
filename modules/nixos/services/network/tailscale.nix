{
  config,
  lib,
  pkgs,
  ...
}:
let
  tailscale-port = 41641;
in
{
  options = {
    tailscale.enable = lib.mkEnableOption "tailscale";
  };

  config = lib.mkIf config.tailscale.enable {
    services.tailscale = {
      enable = true;
      package = pkgs.unstable.tailscale;
      port = tailscale-port;
      useRoutingFeatures = "client";
      extraUpFlags = [
        "--accept-routes"
      ];
    };

    networking = {
      # Configure MagicDNS for Tailscale
      # nameservers = ["100.100.100.100" "1.1.1.1" "8.8.8.8"];
      # search = ["sparrow-yo.ts.net" "king-little.ts.net"];
      firewall = {
        # always allow traffic from your Tailscale network
        trustedInterfaces = [ "tailscale0" ];
        # allow the Tailscale UDP port through the firewall
        allowedTCPPorts = [ tailscale-port ];
        # https://github.com/tailscale/tailscale/issues/4432#issuecomment-1112819111
        checkReversePath = "loose";
      };
    };

    boot.kernel.sysctl = {
      # https://github.com/tailscale/tailscale/issues/3310#issuecomment-1722601407
      "net.ipv4.conf.default.rp_filter" = 2;
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };
}
