# Cloudflared

This flake uses Cloudflare Tunnel (`cloudflared`) to expose selected services without opening direct inbound ports on the origin hosts.

## Module Location

- Base wrapper module: `modules/nixos/services/network/cloudflared.nix`
- Cloudflared service module: `modules/nixos/services/network/cloudflared/new.nix`

## One-Time Tunnel Bootstrap

Run these commands on the host where you manage tunnels:

```sh
cloudflared login
cloudflared tunnel create <name>
sudo mkdir -p /etc/cloudflared
sudo cp /home/mirza/.cloudflared/cert.pem /etc/cloudflared/cert.pem
```

Notes:

- `cloudflared login` creates `~/.cloudflared/cert.pem`.
- `cloudflared tunnel create <name>` creates tunnel credentials JSON under `~/.cloudflared/`.
- The cert file is needed for declarative tunnel management workflows.

## Secrets Wiring

Store tunnel credentials in `secrets/secrets.yaml` under:

- `config.cloudflared.<host>`

Example existing keys:

- `config.cloudflared.sado`
- `config.cloudflared.kuchiki`
- `config.cloudflared.madara`

For a new ingress host (for example `aizen`), add:

- `config.cloudflared.aizen`

The module reads from `config/cloudflared/${config.networking.hostName}`.

## Host Configuration Pattern

Enable cloudflared on the host and define ordered ingress rules:

```nix
services.cloudflared = {
  enable = true;
  defaultDomain = "arnaut.me";
  tunnels."${config.networking.hostName}".ingress = [
    {
      hostname = "arr.${config.services.cloudflared.defaultDomain}";
      path = "/radarr.*";
      service = "http://kuchiki.${config.services.tailscale.tailnet}.ts.net:${builtins.toString config.services.radarr.settings.server.port}";
    }
    {
      hostname = "arr.${config.services.cloudflared.defaultDomain}";
      path = "/sonarr.*";
      service = "http://kuchiki.${config.services.tailscale.tailnet}.ts.net:${builtins.toString config.services.sonarr.settings.server.port}";
    }
    {
      hostname = "arr.${config.services.cloudflared.defaultDomain}";
      path = "/lidarr.*";
      service = "http://sado.${config.services.tailscale.tailnet}.ts.net:${builtins.toString config.services.lidarr.settings.server.port}";
    }
    {
      hostname = "arr.${config.services.cloudflared.defaultDomain}";
      path = "/prowlarr.*";
      service = "http://shinji.${config.services.tailscale.tailnet}.ts.net:${builtins.toString config.services.prowlarr.settings.server.port}";
    }
  ];
};
```

Important details:

- Rules are matched in order.
- `path` supports regex matching (for example `/radarr.*`).
- A default catch-all service (`http_status:404`) is configured by module defaults.

## Deploy and Verify

After secrets + host config are in place:

```sh
sudo nixos-rebuild switch --flake ~/.config/flake#<host>
```

Check service status:

```sh
systemctl status cloudflared-tunnel-<host>
```

Verify external routes:

- `https://arr.arnaut.me/radarr`
- `https://arr.arnaut.me/sonarr`
- `https://arr.arnaut.me/lidarr`
- `https://arr.arnaut.me/prowlarr`

## Troubleshooting

- Missing or wrong secret path: verify `config.cloudflared.<host>` exists in `secrets/secrets.yaml`.
- Service unreachable: verify Tailnet DNS/host reachability from ingress host.
- Path not matching: confirm `hostname` and regex `path` values in ingress rules.
- Auth behavior unexpected: check Cloudflare Access app/policy scope for the hostname and path.
