# Options

All options live under `steamos.*`. Anything not listed here is configured
through upstream nixpkgs options (`programs.steam.*`, `programs.gamescope.*`).

## Core

### `steamos.enable`

Type `bool`, default `false`. Master switch. Enables `programs.steam` and
`programs.gamescope`, and registers this module's own Gaming Mode session.

It also sets `programs.steam.gamescopeSession.enable = false` — nixpkgs'
session and this one both register `steam.desktop`, and this one is a superset
(see [How it works](./how-it-works.md#the-gaming-mode-session)).

### `steamos.user`

Type `null or str`, default `null`. The user the Gaming Mode session runs as.
Required when `autoStart` is on — that user is logged in without a password
prompt.

In this repo the adapter defaults it to `users.primaryUser`.

### `steamos.autoStart`

Type `bool`, default `true`. Boot straight into Gaming Mode by owning the
login path with a greetd session loop. Cannot be combined with a regular
display manager (greetd aliases `display-manager.service`); in this repo the
adapter switches the `desktop` tag's display manager off automatically.

With `autoStart = false` the module only registers the "Steam" session: pick
it from your own display manager's session chooser; session *switching* (which
relies on the loop) is not available.

### `steamos.desktopSession`

Type `null or str`, default `null`, example `"gnome"`. The Wayland session
started by "Switch to Desktop" — a name from
`services.displayManager.sessionData.sessionNames` (the basename of a
`wayland-sessions/*.desktop` file). An unknown name is an eval-time error
listing the valid ones; `null` keeps you in Gaming Mode (with a warning).

The session itself must be enabled through your normal configuration
(`services.desktopManager.gnome.enable`, `plasma6.enable`, …) — this option
only selects it.

### `steamos.steamArgs`

Type `list of str`, default
`[ "-gamepadui" "-steamos3" "-steampal" "-steamdeck" "-pipewire-dmabuf" ]`.
Arguments Steam is launched with inside Gaming Mode — the set Valve's own
`steam-launcher` uses, plus `-pipewire-dmabuf` for Remote Play.

Leave `-steamos3` in place: it is what ties Steam into gamescope's focus
handling and puts "Switch to Desktop" in the power menu.

## Display features

Each of these does two things: passes the gamescope flag, *and* sets the
`STEAM_GAMESCOPE_*` variable that makes the matching toggle appear in Gaming
Mode's settings. Steam reads those once at startup and simply believes them,
so they are tied to the flag rather than exposed separately.

| Option | Default | gamescope flag | Steam capability |
|--------|---------|----------------|------------------|
| `steamos.hdr.enable` | `true` | `--hdr-enabled` | `STEAM_GAMESCOPE_HDR_SUPPORTED` |
| `steamos.vrr.enable` | `true` | `--adaptive-sync` | `STEAM_GAMESCOPE_VRR_SUPPORTED` |
| `steamos.tearing.enable` | `false` | `--immediate-flips` | `STEAM_GAMESCOPE_TEARING_SUPPORTED` |
| `steamos.mangoapp.enable` | `true` | `--mangoapp` | `STEAM_USE_MANGOAPP` |

- **HDR** is safe to leave on for SDR displays — gamescope only drives HDR
  when the connected output advertises it. It needs the WSI layer below for
  games to hand HDR swapchains through; without it, HDR content is tonemapped
  to SDR. Turn it on per game in Gaming Mode's display settings.
- **VRR** is likewise ignored when the output does not support FreeSync.
- **Tearing** is off by default: it trades visible tearing for latency, and
  VRR is the better answer on displays that have it.
- **mangoapp** is what backs Steam's built-in "Performance Overlay" levels;
  it is not the same thing as running MangoHud on a game yourself.


### `steamos.mangoapp.fontScale`

Type `null or float/int`, default `null`. Multiplier for the performance
overlay's size — MangoHud's `font_scale`, which scales the panel as well as the
text.

MangoHud draws the overlay at a fixed size chosen for the Steam Deck's
1280x800 panel, so it shrinks to an unreadable speck on a big television. The
default scales it automatically against the tallest connected output (about
1.8x at 1440p, 2.7x at 2160p), which keeps it roughly Deck-sized. Set a number
to pin it, or `1` for MangoHud's own sizing.

It is applied through `MANGOHUD_CONFIG` rather than the config file, because
Steam rewrites that file on every level change; `read_cfg` is included so the
file — and with it Steam's preset — is still read.

### `steamos.mangoapp.backgroundAlpha`

Type `null or float/int`, default `0.8`. Opacity of the performance overlay's
backdrop, from `0` (invisible) to `1` (solid). MangoHud defaults to `0.5`,
which is legible on a monitor an arm's length away and washes out into the game
from across a living room. `null` leaves MangoHud's own default alone.

### `steamos.realtime.enable`

Type `bool`, default `false`. Adds `--rt` and gives gamescope `cap_sys_nice`
through `programs.gamescope.capSysNice`, letting it renice itself for smoother
frame pacing.

Off by default because the capability puts gamescope in secure-execution mode,
where the loader ignores `LD_LIBRARY_PATH`/`LD_PRELOAD` — which has
historically broken launching it out of Steam's FHS environment. Turn it on,
reboot, and confirm Gaming Mode still starts before keeping it.

## gamescope

### `steamos.gamescope.args`

Type `list of str`, default `[ ]`. Extra arguments appended to the gamescope
command line, after the ones derived from the options above. One list element
per argv entry:

```nix
steamos.gamescope.args = [
  "--output-width"
  "3840"
  "--output-height"
  "2160"
  "--nested-refresh"
  "120"
];
```

### `steamos.gamescope.env`

Type `attrs of str`, default `{ }`. Extra environment for the session,
exported last so it overrides the module's own defaults.

### `steamos.gamescope.wsi.enable`

Type `bool`, default `true`. Installs the gamescope WSI Vulkan layer
(`VK_LAYER_FROG_gamescope_wsi`) into `hardware.graphics.extraPackages` and
`extraPackages32`, and sets `ENABLE_GAMESCOPE_WSI=1` for the session.

The layer is how games present *through* gamescope instead of through plain
Xwayland WSI; it carries frame pacing, the framerate limiter, and HDR
swapchains. Requires `hardware.graphics.enable32Bit` (asserted).

### `steamos.gamescope.wsi.package` / `.package32`

Defaulting to `pkgs.gamescope-wsi` and `pkgs.pkgsi686Linux.gamescope-wsi`. The
layer speaks a versioned protocol to gamescope, so override these to keep it in
step with a non-default `programs.gamescope.package`:

```nix
programs.gamescope.package = pkgs.unstable.gamescope;
steamos.gamescope.wsi = {
  package = pkgs.unstable.gamescope-wsi;
  package32 = pkgs.unstable.pkgsi686Linux.gamescope-wsi;
};
```

## `steamos.tweaks.enable`

Type `bool`, default `true`. SteamOS' opinionated system tuning, minus
everything specific to Valve's hardware. Every setting below is a `mkDefault`,
so an individual one can be overridden without turning the group off.

| Setting | Why |
|---------|-----|
| `zramSwap` — zstd, 50% of RAM, priority 100 | A console has no swap partition to fall back on, and shader compilation, Proton and a browser-based UI will happily use everything. |
| `services.earlyoom` — 5% free memory and swap | Under pressure the kernel's own OOM killer arrives long after the machine stopped responding, which on a controller-driven box means reaching for the power button. |
| `net.ipv4.tcp_mtu_probing = 1` | Some storefronts and matchmaking services sit behind PMTU black holes. |
| `net.ipv4.tcp_fin_timeout = 5` | A game killed and relaunched cannot rebind its port while the old socket lingers, and the default timeout is far longer than a relaunch takes. |

## What else the module sets

Beyond the session itself:

| Setting | Why |
|---------|-----|
| `security.pam.loginLimits` — hard `nice` of `-8` for `steamos.user` | Proton runs some threads at negative niceness. Scoped to the account the session logs in as, not system-wide. |
| A polkit rule for NetworkManager, when `steamos.user` is set and `networking.networkmanager.enable` is on | Gaming Mode's Wi-Fi settings write *system* connections, which normally needs the `networkmanager` group — impossible to grant mid-setup with only a controller in hand. Scoped to that one user's local, active session; Jovian grants it to everyone in `users`. |

Controller access is deliberately **not** handled here. `programs.steam` turns
on `hardware.steam-hardware`, which installs Valve's `steam-devices` rules —
those already tag `/dev/uinput` for the active session and carry `uaccess`
rules for every controller Steam supports. A blanket
`KERNEL=="hidraw*", TAG+="uaccess"` would hand the session every HID device on
the machine, which is more than Valve grants on a Deck. If you have a pad that
Valve's list misses, add a rule for that device.

## `steamos.decky-loader`

[Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader) injects a
plugin menu into Steam's Gaming Mode UI.

| Option | Type | Default | Purpose |
|--------|------|---------|---------|
| `.enable` | `bool` | `false` | Run the loader. |
| `.package` | `null or package` | `pkgs.decky-loader or null` | What to run. |
| `.user` | `str` | `"decky"` | Unprivileged user plugins run as; created automatically when left at the default. |
| `.stateDir` | `path` | `/var/lib/decky-loader` | Installed plugins and their data. |
| `.extraPackages` | `list of package` | `[ ]` | Extra tools on the loader's `PATH`, for plugins that shell out. |
| `.extraPythonPackages` | `function` | `_: [ ]` | Extra Python modules importable by plugins, as a function of the interpreter's package set. |

**nixpkgs does not package Decky Loader.** `package` therefore defaults to
`pkgs.decky-loader` only when something has provided it, and to `null`
otherwise — in which case the module configures nothing and emits a warning
rather than failing to evaluate. That keeps this tree usable against a bare
nixpkgs, which is the same constraint the rest of it follows. This repo builds
one in `packages/top-level/decky-loader`, so `pkgs.decky-loader` resolves here;
elsewhere, supply your own:

```nix
steamos.decky-loader = {
  enable = true;
  package = inputs.somewhere.packages.${pkgs.system}.decky-loader;
  extraPythonPackages = ps: [ ps.hid ];
};
```

The service runs as **root** and drops to `user` for plugins. That is upstream's
design, not an oversight — running the loader unprivileged is unsupported and
[breaks](https://github.com/SteamDeckHomebrew/decky-loader/issues/446).

### What the module does for Decky beyond running it

Decky does not draw its own window — it injects into Steam's UI over the CEF
debugger that `steamwebhelper` opens on `127.0.0.1:8080`, and Steam only opens
that when `.cef-enable-remote-debugging` exists in its data directory at
startup. Without it the loader starts, serves happily on port 1337, and is
simply never visible in Gaming Mode.

So the module creates that file in `steamos.user`'s Steam directory. **Steam
has to be restarted afterwards** — switching the configuration is not enough,
since Steam only reads the flag when it launches.

Be aware of what that implies: an unauthenticated debugger into the Steam
client, bound to loopback, for as long as Decky is enabled. That is inherent to
how Decky works, not something this module adds on top.

The service also gets `lsof` and `systemctl` on its `PATH` — the loader uses
the first to find that CEF socket and the second to manage its own unit.

### `steamos.decky-loader.plugins`

Type `list of package`, default `[ ]`. Plugins installed declaratively:

```nix
steamos.decky-loader.plugins = with pkgs.deckyPlugins; [
  hltb-for-deck
  protondb-decky
];
```

Each is symlinked into the plugin directory. Decky scans that directory for
subdirectories containing a `plugin.json` and resolves symlinks on the way, so
store paths load exactly like installed ones.

**This composes with the in-game store rather than replacing it.** Plugins
installed through Decky's UI are ordinary directories sitting alongside these
symlinks, and keep working and updating as normal — so you can declare the ones
you rely on and still try something from the store without touching your
configuration.

What a declared plugin gives up is Decky's own updater: its version is whatever
the package pins, so updating means bumping the package. Uninstalling one from
the UI removes only the symlink, which the next boot restores — declarative
wins, which is the point, but it is a behaviour change worth knowing.

Per-plugin *settings and data* are unaffected either way. Decky keeps those in
`settings/<plugin>` and `data/<plugin>` beside the plugin directory, never
inside it, which is exactly what makes read-only store paths workable here.

Plugins are packaged in `packages/deckyPlugins/`, built by `buildDeckyPlugin`
from the prebuilt tarball each plugin publishes per release. Adding one is a
handful of lines — `pname`, `version`, `owner`, `hash`.
