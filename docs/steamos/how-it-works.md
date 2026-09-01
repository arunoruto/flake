# How it works

Eight pieces, eight files:

| File | Piece |
|------|-------|
| `gaming-mode.nix` | The Gaming Mode session: the gamescope session script, and the system-level bits it depends on. |
| `session-select.nix` | The `steamos-session-select` switcher Steam calls, plus the "Return to Gaming Mode" desktop entry. |
| `autostart.nix` | The default login path: a greetd session loop running the `steamos-session` launcher. |
| `sddm.nix` | The SteamOS-shaped login path: SDDM autologin plus SteamOS Manager, behind `steamos.loginManager = "sddm"`. |
| `tweaks.nix` | SteamOS' system tuning — zram, earlyoom, a couple of network sysctls — behind `steamos.tweaks.enable`. |
| `decky-loader.nix` | The Decky plugin loader service, behind `steamos.decky-loader.enable`. |
| `manager.nix` | The SteamOS Manager daemon, behind `steamos.manager.enable`. |
| `default.nix` | Options, assertions, warnings. |

## The Gaming Mode session

nixpkgs has `programs.steam.gamescopeSession`, and this module used to just
turn it on. It boils Valve's session down to:

```sh
gamescope --steam -- steam -tenfoot
```

That is enough to *see* Gaming Mode, but not enough for it to behave, because
Steam decides at startup what Gaming Mode can do by reading its environment,
and expects a compositor set up a particular way. So the module ships its own
session script — `steamos-gamescope-session`, registered as `steam.desktop`,
the same session name — modelled on Valve's `gamescope-session` with the Steam
Deck hardware parts removed.

The parts that matter:

**Two Xwayland servers** (`--xwayland-count 2` + `STEAM_MULTIPLE_XWAYLANDS=1`).
SteamOS gives the Deck UI one X server and isolates games onto a second one.
With a single server the Steam UI and the game share one focus stack, and the
Steam-button overlay strands focus on the way out: the game keeps running but
stops being drawn and stops receiving input, until something forces Steam to
re-assert focus (opening a full-screen view, or "Resume" on the game's page).

**The WSI layer** (`ENABLE_GAMESCOPE_WSI=1` plus `gamescope-wsi` in
`hardware.graphics.extraPackages{,32}`). `VK_LAYER_FROG_gamescope_wsi` is how a
game's Vulkan swapchain is handed to gamescope directly. It carries frame
pacing, the framerate limiter, and HDR — without it HDR content is tonemapped
down to SDR no matter what else is enabled.

**Capability flags** — the `STEAM_GAMESCOPE_*` and `STEAM_*` variables. These
are not gamescope settings; Steam reads them once and believes them, and they
are what makes toggles (HDR, VRR, tearing, scaling filters, the performance
overlay) appear in Gaming Mode's menus. The module only advertises what this
session actually provides, which is why the Deck-specific ones (fan control,
backlight, status LED, CEC, drive adoption) are absent, along with the ones
that depend on Valve's patched Mesa (dynamic VRS, the fifo fps limiter).

**Session type.** `XDG_SESSION_TYPE=x11`: Steam and its games are X11 clients
of gamescope's Xwayland servers, whatever the login path called the session.

**Runtime state.** The script creates gamescope's mode-save file, the limiter
fifo, and seeds the mangoapp config — the reason a plain `env`-and-`args`
option pair could not express this session.

**The performance overlay** is one place this module knowingly diverges from
Valve, in two halves.

The config file: Steam selects a level 0–4 by writing `preset=N` into
`~/.local/share/Steam/config/mangohud.conf` and then running
`mangohudctl toggle reload_config`, which makes mangoapp re-parse its config.
Valve's script points `MANGOHUD_CONFIGFILE` at a fresh `mktemp` instead, so
mangoapp ends up watching a file Steam never writes and every level looks the
same. This module points it at the file Steam actually writes, and seeds it
only when absent so an existing level survives.

The presets: the module defines what each level *contains* itself, through
`MANGOHUD_PRESETSFILE` — MangoHud's built-ins minus the Deck's battery
readouts, sized for the connected display at session start
(`steamos.mangoapp.fontScale`). The presets file is the only place sizing can
live: Steam rewrites the config file on every level change, and
`MANGOHUD_CONFIG` makes MangoHud apply the preset twice — every element drawn
double. The dense levels get their own, narrower scale, computed so the widest
table row still fits the display.

## The login loop

With `steamos.autoStart` on the default greetd path, there is no display
manager and no greeter (`loginManager = "sddm"` swaps this whole section for
SDDM autologin — see `sddm.nix` and the switching notes below). greetd's
`default_session` is used kiosk-style: it runs the `steamos-session` launcher
directly as `steamos.user`, and whenever the session ends — Steam shut down,
desktop logged out, compositor crashed — greetd simply runs it again.

The launcher does the part a display manager would normally do:

1. Read (and delete) the one-shot selection file
   `~/.local/state/steamos-session-select`; default to the `steam` session
   when it is absent.
2. Resolve `<session>.desktop` in the collected
   `services.displayManager.sessionData.desktops` output — the same session
   registry GDM/SDDM would consult, so anything that registers a Wayland
   session (GNOME, Plasma, the gamescope Steam session, …) is launchable.
3. Export the session identity (`XDG_SESSION_TYPE`, `XDG_SESSION_DESKTOP`,
   `XDG_CURRENT_DESKTOP` from the file's `DesktopNames=`), push it into the
   systemd user manager and D-Bus activation environment, and `exec` the
   file's `Exec=` line.

### Where the session's output goes

greetd hands its child the console, so a session started this way prints to
whichever display owns `fbcon` — which is not necessarily the GPU the session
renders on, and is unreachable over SSH. A Gaming Mode that fails to start then
leaves a black screen and no way to ask why. The launcher runs the session
under `systemd-cat` instead, so it is all in the journal:

```sh
journalctl -t steamos-session
```

`systemd-cat` execs the session rather than forking it, so greetd still sees
one child and its bookkeeping is unchanged.

The Gaming Mode script also wraps *itself* the same way when nothing else has
(guarded by `STEAMOS_SESSION_JOURNAL`, which the greetd launcher sets to
prevent double-wrapping) — SDDM runs the `.desktop` file directly, and without
this its sessions logged nowhere at all.

### Making the session look like a session

Occupying greetd's *greeter* slot is what buys the respawn loop, and it is
also what nearly makes Desktop Mode impossible. greetd never sets
`XDG_SESSION_TYPE` at all and marks its sessions `XDG_SESSION_CLASS=greeter`,
so logind registers every one of them as `class=greeter type=tty`. Gaming Mode
does not care — gamescope, like every wlroots compositor, promotes its own
session type once it holds the DRM device — but a desktop does:

- GNOME's shell unit carries `AssertEnvironment=XDG_SESSION_TYPE=wayland`;
- a `type=tty` session is never eligible to be the user's logind *display*
  session, and mutter refuses to start without a logind session it can
  resolve.

So the module fixes it at both ends. A `pam_env` rule on the greetd PAM
service — ordered after the base one and well before `pam_systemd` — sets
`XDG_SESSION_TYPE=wayland` and `XDG_SESSION_CLASS=user`, so logind *creates*
the session correctly instead of it being corrected afterwards. And step 3
above pushes the identity into the systemd user manager, because gnome-shell
runs as a user service (`org.gnome.Shell@.service`) and would otherwise
inherit none of it.

Because the selection file is consumed on every cycle, **Gaming Mode is
always the fallback**: rebooting, logging out of the desktop, or a crashed
session all land back in Steam. This mirrors SteamOS.

## Session switching

The mechanism depends on `steamos.loginManager`. What follows describes the
default greetd path; on the SDDM path the work is SteamOS Manager's — Steam
calls its `SessionManagement1` D-Bus interface, the manager writes an SDDM
autologin drop-in naming the target session and stops
`graphical-session.target`, and SDDM's `Relogin` starts whatever the drop-in
named. Since gamescope is a plain child of `sddm-helper` rather than a session
unit, the Gaming Mode script parks a stand-in `gamescope-session.service` in
that target whose stop shuts Steam down cleanly — without it, stopping the
target would do nothing and "Switch to Desktop" hung forever. The
`steamos-session-select` script still exists on that path, delegating to
`steamosctl`, so the desktop's "Return to Gaming Mode" entry works the same
either way.

SteamOS exposes switching through a `steamos-session-select` executable, and
the Steam client hardcodes calls to it (historically with Valve's KDE session
names, e.g. `steamos-session-select plasma`). The module ships a script with
that name and contract:

- `gamescope` / `steam` → clear the selection (next login: Gaming Mode);
- `desktop` / `plasma*` → write `steamos.desktopSession` into the selection
  file — whatever KDE flavor Steam asks for, you get *your* desktop;
- anything else is taken as a literal session name, for scripting.

It then ends the current session: inside Gaming Mode via a clean
`steam -shutdown` (gamescope exits with Steam), from a desktop via
`loginctl terminate-session`. greetd's loop does the rest.

On the desktop, a **Return to Gaming Mode** launcher entry (the same script,
`gamescope` argument) completes the round trip.

```text
   Gaming Mode (gamescope + steam)
        │  "Switch to Desktop"
        │  steamos-session-select plasma
        │    → writes ~/.local/state/steamos-session-select
        │    → steam -shutdown
        ▼
   greetd respawns steamos-session
        │  reads + deletes the selection file
        ▼
   Desktop session (steamos.desktopSession)
        │  "Return to Gaming Mode" (or plain logout / reboot)
        ▼
   greetd respawns steamos-session → Gaming Mode
```

## Known limitations

- **Wayland only.** X11 sessions would need the `startx` dance; not
  implemented.
- **No crash-loop brake.** If the session dies instantly (e.g. a broken GPU
  driver), greetd respawns it in a tight loop; the launcher only sleeps
  before its own fallback path. Failsafe is the same as SteamOS: switch to
  another VT and log in there.
- **No greeter, no password** in `autoStart` mode — by design, see the
  security note in the [README](./README.md).
- **gamescope runs Steam as its child**, where Valve starts gamescope and
  Steam as separate systemd user units wired together by a ready socket. The
  simpler shape costs the session's D-Bus/systemd integration
  (`gamescope-session.target`, the stats socket other tools consume) but keeps
  the module to one script. The SDDM path papers over the one consumer that
  matters — SteamOS Manager reads and stops `gamescope-session.service` — with
  a stand-in unit, not a real split.
- Valve's deeper integration (steamos-manager D-Bus API, updater, power
  button daemon, per-device quirks) is out of scope; use Jovian if you need
  it.
