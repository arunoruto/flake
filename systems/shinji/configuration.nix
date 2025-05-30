{
  config,
  pkgs,
  lib,
  ...
}:
{
  colmena.deployment = {
    targetHost = config.networking.hostName;
    tags = [ "tinypc" ];
  };
  hosts.tinypc.enable = true;
  hosts.intel.enable = true;
  kodi.enable = true;
  bosflix = {
    enable = true;
    drivePath = /media/86336459-5d8c-448e-93c3-f3e17c00d3b91;
  };
  # tpm.enable = true;
  media.external-drives.enable = true;

  # plex.enable = true;
  services = {
    plex = {
      enable = true;
      accelerationDevices = [ "/dev/dri/renderD128" ];
    };
    xrdp = {
      enable = true;
      defaultWindowManager = "kodi";
    };
    ipv64-dyndns = {
      enable = true;
      domainKeyPath = config.sops.secrets."tokens/ipv64/orahovica".path;
    };
    qbittorrent = {
      enable = true;
      webuiPort = 8081;
    };
    traefik.enable = true;
    cloudflared = {
      enable = true;
      package = pkgs.cloudflared;
      tunnels = {
        "bosflix" = {
          credentialsFile = "${config.sops.secrets."config/bosflix".path}";
          default = "http_status:404";
          # ingress = {
          #   "*.domain1.com" = {
          #     service = "http://localhost:80";
          #     path = "/*.(jpg|png|css|js)";
          #   };
          #   "*.domain2.com" = "http://localhost:80";
          # };
        };
      };
    };
  };

  security.pki.certificateFiles = [
    ./rhtv.pem
  ];

}
