# Monitoring (Gatus)

[Gatus](https://gatus.io) runs on **aizen**, the VPS, so it keeps alerting when
the home network or power is down. Its status page is tailnet-only:
`http://aizen.<tailnet>.ts.net:8090`.

Alerts go to the same ntfy topic as the auto-upgrades (`tokens/ntfy/upgrade`),
titled "Gatus", once when something breaks and once when it recovers.

## What it watches

Both lists live in `systems/x86_64-linux/aizen/configuration.nix`:

- **`services.gatus.httpChecks`**: public hostnames, checked over HTTPS every
  5 minutes. A check passes if the server answers with anything below 500
  (login redirects and 401s count as up). No answer, or Cloudflare's 502/530
  for a dead origin or tunnel, fails. It alerts after 3 failures in a row.
- **`services.gatus.tailnetChecks`**: the apps themselves, checked directly
  over the tailnet every 5 minutes and grouped by host on the status page
  (radarr, sonarr, lidarr, prowlarr and bazarr's `/ping`, Immich's
  `/api/server/ping`, Plex's `/identity` on each host, Jellyfin, SABnzbd,
  qBittorrent). These matter because publicly, Cloudflare Access answers for
  `arr.arnaut.me` and stays green even when the *arrs are down. A broken
  tunnel and a broken app also show up as separate alerts.
- **`services.gatus.upgradeHeartbeats`**: hosts whose `nixos-upgrade` checks in
  after every successful run (see [Automatic upgrades](./auto-upgrade.md)). A
  host with no check-in for 26 hours, because it skipped, failed or never
  ran, raises an alert.

The lists are written out by hand on purpose. Generating them from every
host's tunnel config would evaluate the whole fleet inside aizen's config,
which costs gigabytes of memory on every evaluation.

## Adding things

- A new public service: add its hostname to `httpChecks`.
- A new app: add it to `tailnetChecks` with its host, port and health path,
  plus a `body` condition if it has a real health response.
- A host rolled out to auto-upgrades: add it to `upgradeHeartbeats` after its
  first deploy. Before that it never checks in and would alert.

The module (`modules/nixos/services/gatus.nix`) is a thin layer over nixpkgs'
`services.gatus`; anything else goes into `services.gatus.settings` as in
Gatus's own documentation. Secrets are referenced as `${VAR}` and come from the
`gatus.env` sops template.
