# Monitoring (Gatus)

[Gatus](https://gatus.io) runs on **aizen**, the VPS, so it keeps alerting when
the home network or power is down. Its status page is tailnet-only:
`http://aizen.<tailnet>.ts.net:8090`.

Alerts go to the same ntfy topic as the auto-upgrades (`tokens/ntfy/upgrade`),
titled "Gatus", once when something breaks and once when it recovers.

## What it watches

- **`services.gatus.httpChecks`** (aizen's config): public hostnames, checked
  over HTTPS every 5 minutes. A check passes if the server answers with
  anything below 500 (login redirects and 401s count as up). No answer, or
  Cloudflare's 502/530 for a dead origin or tunnel, fails. It alerts after 3
  failures in a row.
- **`services.gatus.tailnetChecks`** (each service's own module): the apps
  themselves, checked directly over the tailnet every 5 minutes, grouped by
  function on the status page (arr, media, downloads, with the host in the
  name: "plex (sado)"). These matter because publicly, Cloudflare Access
  answers for `arr.arnaut.me` and stays green even when the *arrs are down. A
  broken tunnel and a broken app also show up as separate alerts.
- **`services.gatus.upgradeHeartbeats`** (aizen's config): hosts whose
  `nixos-upgrade` checks in after every successful run (see
  [Automatic upgrades](./auto-upgrade.md)). A host with no check-in for 26
  hours, because it skipped, failed or never ran, raises an alert.

### How the app checks reach aizen

A module declares its check on the host it runs on, next to its traefik router
(the *arrs all get theirs from `lib.arr.arrConfig`; `host` defaults to the
declaring host). Aizen cannot read those directly: every other host's config
would be evaluated inside aizen's own, on every rebuild and every nightly
upgrade. Instead `scripts/gatus-checks.sh` evaluates each host in turn and
writes all checks to `modules/nixos/services/gatus-checks.json`, which aizen
reads. The Update Lockfile workflow regenerates it with every run and pushes
it through the same build gate as the lock.

## Adding things

- A new public service: add its hostname to `httpChecks`.
- A new app: add a `services.gatus.tailnetChecks` entry to its module, inside
  its enable guard, with its port and health path plus a `body` condition if
  it has a real health response. Then run `just gatus-checks` and commit the
  JSON, or let the next CI run pick it up.
- A host rolled out to auto-upgrades: add it to `upgradeHeartbeats` after its
  first deploy. Before that it never checks in and would alert.

The module (`modules/nixos/services/gatus.nix`) is a thin layer over nixpkgs'
`services.gatus`; anything else goes into `services.gatus.settings` as in
Gatus's own documentation. Secrets are referenced as `${VAR}` and come from the
`gatus.env` sops template.
