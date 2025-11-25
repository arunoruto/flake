{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./tailscale

    ./avahi.nix
    ./cloudflared.nix
    ./ipv64.nix
    ./localsend.nix
    ./netbird.nix
    ./traefik.nix
  ];

  config = {
    services = {
      avahi.enable = true;
      tailscale = {
        enable = lib.mkDefault true;
        tailnet = lib.mkDefault "sparrow-yo";
      };
      netbird.enable = lib.mkDefault false;
    };
    programs.localsend.enable = lib.mkDefault true;
    environment.systemPackages =
      lib.optionals (!(lib.elem "tinypc" config.system.tags)) (
        with pkgs;
        [
          bind
          wireguard-tools
        ]
      )
      ++ lib.optionals config.networking.wireless.iwd.enable [
        pkgs.impala
      ];

    networking = {
      networkmanager = {
        enable = true;
        wifi = {
          powersave = lib.elem "laptop" config.system.tags;
          backend = lib.mkDefault "wpa_supplicant";
        };
      };
      firewall = {
        enable = true;
        allowedTCPPorts = [
          1313 # hugo
          3390 # RDP
        ];
        allowedUDPPorts = [
          # 69 # tftp
        ];
      };
      wireless.iwd.settings = {
        DriverQuirks = {
          UseDefaultInterface = true;
        };
        Settings = {
          AutoConnect = true;
        };

      };
    };

  };
}
