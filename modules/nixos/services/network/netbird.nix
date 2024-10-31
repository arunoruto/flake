{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.netbird.enable = lib.mkEnableOption "Enable netbird";

  config = lib.mkIf config.netbird.enable {
    services.netbird = {
      enable = true;
      package = pkgs.unstable.netbird;
      # port = tailscale-port;
      # useRoutingFeatures = "client";
      # extraUpFlags = [
      #   "--accept-routes"
      # ];
    };

    environment.systemPackages = with pkgs; [
      unstable.netbird-ui
    ];

    # networking = {
    #   # Configure MagicDNS for Tailscale
    #   # nameservers = ["100.100.100.100" "1.1.1.1" "8.8.8.8"];
    #   # search = ["sparrow-yo.ts.net" "king-little.ts.net"];
    #   firewall = {
    #     # always allow traffic from your Tailscale network
    #     trustedInterfaces = ["tailscale0"];
    #     # allow the Tailscale UDP port through the firewall
    #     allowedTCPPorts = [tailscale-port];
    #     # https://github.com/tailscale/tailscale/issues/4432#issuecomment-1112819111
    #     checkReversePath = "loose";
    #   };
    # };

    # # https://github.com/tailscale/tailscale/issues/3310#issuecomment-1722601407
    # boot.kernel.sysctl = {
    #   "net.ipv4.conf.default.rp_filter" = 2;
    # };
  };
}
