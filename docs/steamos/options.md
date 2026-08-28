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

## What else the module sets

Beyond the session itself:

| Setting | Why |
|---------|-----|
| `security.pam.loginLimits` — hard `nice` of `-8` for `steamos.user` | Proton runs some threads at negative niceness. Scoped to the account the session logs in as, not system-wide. |
| A polkit rule for NetworkManager, when `steamos.user` is set and `networking.networkmanager.enable` is on | Gaming Mode's Wi-Fi settings write *system* connections, which normally needs the `networkmanager` group — impossible to grant mid-setup with only a controller in hand. Scoped to that one user's local, active session; Jovian grants it to everyone in `users`. |
| `net.ipv4.tcp_mtu_probing = 1`, `net.ipv4.tcp_fin_timeout = 5` | PMTU black holes break some storefronts; a game killed and relaunched cannot rebind its port while the old socket lingers. Both `mkDefault`. |

Controller access is deliberately **not** handled here. `programs.steam` turns
on `hardware.steam-hardware`, which installs Valve's `steam-devices` rules —
those already tag `/dev/uinput` for the active session and carry `uaccess`
rules for every controller Steam supports. A blanket
`KERNEL=="hidraw*", TAG+="uaccess"` would hand the session every HID device on
the machine, which is more than Valve grants on a Deck. If you have a pad that
Valve's list misses, add a rule for that device.
