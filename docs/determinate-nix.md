# Determinate Nix

[Determinate Nix](https://docs.determinate.systems/) is Determinate Systems'
downstream distribution of Nix (flakes enabled by default, `lazy-trees`, its own
`determinate-nixd` daemon). This flake **used** to run it on every host; it has
since been removed in favour of the stock Nix that ships with `nixpkgs`.

This page documents how it was wired in so it can be re-enabled if ever needed —
and the one gotcha (source rebuilds) that made it painful.

## Why it was removed

The `determinate` module pins a specific `determinate-nix-<version>` build. That
build is published as a **binary on the FlakeHub cache**, but this flake never
listed `https://cache.flakehub.com` as a substituter — only its public key was
present (see the gotcha below). So every version bump rebuilt Determinate Nix
(and its `boost` etc. dependencies) **from source** during `nh os switch`, which
was slow enough to not be worth it. Stock Nix already covers everything this
config needs (flakes, `nix-command`, `pipe-operators` are enabled in
`modules/nixos/system/nix-utils.nix` and `modules/darwin/system/nix.nix`,
independent of Determinate).

## How to re-enable it

Three edits, then rebuild:

1. **Add the flake input** (`flake.nix`):

   ```nix
   determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
   ```

2. **Import the module** for the relevant platform (`systems/default.nix`) — it
   lives in the `nixosModules` / `darwinModules` list:

   ```nix
   # in nixosModules
   determinate.nixosModules.default
   # in darwinModules
   determinate.darwinModules.default
   ```

3. **Add the FlakeHub cache substituter** (`flake.nix` → `nixConfig`). This is
   the important one — without it, Determinate Nix builds from source:

   ```nix
   extra-substituters = [
     # …
     "https://cache.flakehub.com"
   ];
   extra-trusted-public-keys = [
     # …
     "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
   ];
   ```

Then `just switch` (NixOS) / `just switch` on the darwin host.

> **The gotcha:** `install.determinate.systems` is the *installer* host, not a
> binary cache. The Determinate Nix binaries live on `cache.flakehub.com`. If you
> re-add the module but forget the substituter, you'll compile Nix from source on
> every lockfile bump — the exact reason it was removed.

## Platform notes

### NixOS

The `determinate.nixosModules.default` module sets `nix.package` to the
Determinate build and hands daemon management to `determinate-nixd`. Nothing else
in the config depends on it — `nix-command`/`flakes`/`pipe-operators` come from
`modules/nixos/system/nix-utils.nix`, so removing Determinate does not disable
flakes.

### darwin (`tensa`)

On darwin the module sets `nix.enable = false`, telling `nix-darwin` **not** to
manage Nix (Determinate manages it out-of-band via `determinate-nixd`). It also
consumes a `determinateNix.customSettings` option to push the shared `settings`
into Determinate's config.

If you run darwin on **stock** Nix instead, `nix.enable` must be `true` so
`nix-darwin` manages the daemon — otherwise nothing configures Nix on that host.
`modules/darwin/system/nix.nix` is where both live.
