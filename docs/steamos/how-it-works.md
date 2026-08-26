# How it works

Three pieces, three files:

| File | Piece |
|------|-------|
| `session.nix` | The Gaming Mode session (nixpkgs' `programs.steam.gamescopeSession`) and the `steamos-session-select` switcher Steam calls. |
| `autostart.nix` | The login loop: greetd running the `steamos-session` launcher instead of a display manager. |
| `default.nix` | Options, assertions, warnings. |

## The login loop

With `steamos.autoStart`, there is no display manager and no greeter. greetd's
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
   `XDG_CURRENT_DESKTOP` from the file's `DesktopNames=`) and `exec` the
   file's `Exec=` line.

Because the selection file is consumed on every cycle, **Gaming Mode is
always the fallback**: rebooting, logging out of the desktop, or a crashed
session all land back in Steam. This mirrors SteamOS.

## Session switching

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
- Valve's deeper integration (steamos-manager D-Bus API, updater, power
  button daemon, per-device quirks) is out of scope; use Jovian if you need
  it.
