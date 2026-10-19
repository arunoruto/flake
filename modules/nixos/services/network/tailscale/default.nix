{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./derper.nix
    ./tsidp.nix
  ];

  options.services.tailscale = {
    tailnet = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Tailnet name for Tailscale.";
    };

    advertiseRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "192.168.1.0/24" ];
      description = ''
        Physical subnets this host makes reachable from the tailnet.
        Routes still have to be approved in the admin console before
        peers will use them.
      '';
    };
  };

  config =
    let
      cfg = config.services.tailscale;
      tailscale-port = 41641;
    in
    lib.mkIf cfg.enable {
      services.tailscale = {
        package = pkgs.unstable.tailscale;
        port = tailscale-port;
        useRoutingFeatures = "client";
        # extraUpFlags only run via tailscaled-autoconnect, which exists only
        # with an authKeyFile; extraSetFlags run on every activation. So
        # everything `tailscale set` accepts belongs in extraSetFlags.
        extraUpFlags = lib.optionals (config.lib.tags.hasTag "server") [
          "--advertise-tags=tag:connector"
        ];
        # WireGuard talks UDP, so this is the port that has to be reachable.
        # The firewall block below used to put `tailscale-port` in
        # allowedTCPPorts instead — despite its own comment saying UDP — which
        # left TCP 41641 open for nothing and UDP 41641 closed. Outbound
        # traffic still worked (conntrack), so it went unnoticed; what it cost
        # was inbound reachability, i.e. being the fixed endpoint of a direct
        # connection when the peer sits behind a NAT that cannot hole-punch.
        # This option is nixpkgs' own and opens exactly
        # allowedUDPPorts = [ port ].
        openFirewall = true;
        # Advertising (exit node, connector, tailscale-SSH) is a server
        # *role*, keyed on the server tag — not on "doesn't have desktop":
        # a laptop or workstation without the desktop tag must never route
        # tailnet traffic. Everything else is a plain client.
        # A subnet router must not accept routes: in an HA pair the other
        # router's copy of the shared LAN lands in table 52, which outranks
        # main, so replies to on-LAN clients leave via tailscale0 instead.
        # Spelled out as =false because `set` leaves omitted flags as-is.
        extraSetFlags = [
          "--accept-routes=${lib.boolToString (cfg.advertiseRoutes == [ ])}"
        ]
        ++ (
          if (config.lib.tags.hasTag "server") then
            [
              "--ssh"
              "--advertise-connector"
              "--advertise-exit-node"
            ]
          else
            [
              "--exit-node-allow-lan-access"
            ]
        )
        # Lets the desktop tray toggles (GNOME's tailscale-qs, Plasma's
        # ktailctl) switch tailscale without root.
        ++ lib.optional (config.lib.tags.hasTag "desktop") "--operator=${config.users.primaryUser}"
        # `set` replaces the whole route list, so this is also what
        # retracts stale app-connector routes on activation.
        ++ lib.optional (
          cfg.advertiseRoutes != [ ]
        ) "--advertise-routes=${lib.concatStringsSep "," cfg.advertiseRoutes}";
        permitCertUid = if config.services.traefik.enable then "traefik" else null;
      };

      networking = {
        # Configure MagicDNS for Tailscale
        # nameservers = ["100.100.100.100" "1.1.1.1" "8.8.8.8"];
        # search = ["sparrow-yo.ts.net" "king-little.ts.net"];
        firewall = {
          # always allow traffic from your Tailscale network
          trustedInterfaces = [ "tailscale0" ];
          # https://github.com/tailscale/tailscale/issues/4432#issuecomment-1112819111
          checkReversePath = "loose";
        };

        # Forwarding hosts (exit node / subnet router) want UDP GRO forwarding
        # on their physical NICs: https://tailscale.com/s/ethtool-config-udp-gro
        networkmanager.dispatcherScripts =
          lib.mkIf (config.lib.tags.hasTag "server" && config.networking.networkmanager.enable)
            [
              {
                type = "basic";
                source = pkgs.writeShellScript "tailscale-udp-gro" ''
                  if [ "$2" = up ] && [ -e "/sys/class/net/$1/device" ]; then
                    ${lib.getExe pkgs.ethtool} -K "$1" rx-udp-gro-forwarding on rx-gro-list off || true
                  fi
                '';
              }
            ];
      };

      # --accept-routes puts peer subnet routes in table 52, whose rule
      # (5270) outranks main — so when a peer advertises the LAN we are
      # sitting on, replies to LAN neighbours go into the tunnel and
      # die. Consult main first but ignore its default route, so
      # directly connected subnets stay local while everything else
      # (exit node included) still falls through to Tailscale.
      systemd.services.tailscale-prefer-lan =
        let
          rule = "priority 5200 lookup main suppress_prefixlength 0";
          ip = lib.getExe' pkgs.iproute2 "ip";
        in
        {
          description = "Prefer directly connected routes over Tailscale subnet routes";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-pre.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            for family in -4 -6; do
              ${ip} $family rule del ${rule} 2>/dev/null || true
              ${ip} $family rule add ${rule}
            done
          '';
          preStop = ''
            for family in -4 -6; do
              ${ip} $family rule del ${rule} 2>/dev/null || true
            done
          '';
        };

      boot.kernel.sysctl = {
        # https://github.com/tailscale/tailscale/issues/3310#issuecomment-1722601407
        "net.ipv4.conf.default.rp_filter" = 2;
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };

      # systemd = {
      #   # timers.delayed-tailscale-restart = {
      #   #   wantedBy = [ "sysinit-reactivation.target" ];
      #   #   timerConfig = {
      #   #     OnActiveSec = "10m";
      #   #     Unit = "delayed-tailscale-restart.service";
      #   #     RemainAfterElapse = false;
      #   #   };
      #   # };

      #   # services = {
      #   #   delayed-tailscale-restart = {
      #   #     serviceConfig.Type = "oneshot";
      #   #     script = ''
      #   #       old_tailscale_path=$(
      #   #         systemctl show tailscaled.service --property=ExecStart --value |
      #   #         grep -oP 'path=\K[^;]+'
      #   #       )
      #   #       new_tailscale_path=${config.services.tailscale.package}/bin/tailscaled

      #   #       if [ "$old_tailscale_path" != "$new_tailscale_path" ]; then
      #   #         echo "Tailscale updated "
      #   #         echo "old: $old_tailscale_path"
      #   #         echo "new: $new_tailscale_path"
      #   #         echo "Restarting..."
      #   #         systemctl restart tailscaled
      #   #       else
      #   #         echo "Tailscale version unchanged. No restart needed."
      #   #       fi
      #   #     '';
      #   #   };

      #   #   tailscaled.restartIfChanged = false;
      #   # };
      # };
    };
}
