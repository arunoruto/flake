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
  imports = [ ./derper.nix ];

  options.services.tailscale.tailnet = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Tailnet name for Tailscale.";
  };

  config = lib.mkIf config.services.tailscale.enable {
    services.tailscale = {
      package = pkgs.unstable.tailscale;
      port = tailscale-port;
      useRoutingFeatures = "client";
      extraUpFlags =
        [
          "--accept-routes"
        ]
        ++ lib.optionals (config.hosts.tinypc.enable) [
          "--ssh"
        ]
        ++ lib.optionals (!config.hosts.tinypc.enable) [
          "--exit-node-allow-lan-access"
        ];
      extraSetFlags = lib.optionals (config.hosts.tinypc.enable) [
        "--advertise-exit-node"
      ];
      permitCertUid = if config.services.traefik.enable then "traefik" else null;
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

    # systemd = {
    #   timers.delayed-tailscale-restart = {
    #     wantedBy = [ "sysinit-reactivation.target" ];
    #     timerConfig = {
    #       OnActiveSec = "10m";
    #       Unit = "delayed-tailscale-restart.service";
    #       RemainAfterElapse = false;
    #     };
    #   };

    #   services = {
    #     delayed-tailscale-restart = {
    #       serviceConfig.Type = "oneshot";
    #       script = ''
    #         old_tailscale_path=$(
    #           systemctl show tailscaled.service --property=ExecStart --value |
    #           grep -oP 'path=\K[^;]+'
    #         )
    #         new_tailscale_path=${config.services.tailscale.package}/bin/tailscaled

    #         if [ "$old_tailscale_path" != "$new_tailscale_path" ]; then
    #           echo "Tailscale updated "
    #           echo "old: $old_tailscale_path"
    #           echo "new: $new_tailscale_path"
    #           echo "Restarting..."
    #           systemctl restart tailscaled
    #         else
    #           echo "Tailscale version unchanged. No restart needed."
    #         fi
    #       '';
    #     };

    #     tailscaled.restartIfChanged = false;
    #   };
    # };
  };
}
