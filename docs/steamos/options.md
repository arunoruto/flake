# Options

All options live under `steamos.*`. Everything else is configured through
upstream nixpkgs options (`programs.steam.*`, `programs.gamescope.*`).

## `steamos.enable`

Type `bool`, default `false`. Master switch. Enables
`programs.steam` and `programs.steam.gamescopeSession` (both `mkDefault`, so
they can still be overridden or pre-configured elsewhere).

## `steamos.user`

Type `null or str`, default `null`. The user the Gaming Mode session runs as.
Required when `autoStart` is on — that user is logged in without a password
prompt.

In this repo the adapter defaults it to `users.primaryUser`.

## `steamos.autoStart`

Type `bool`, default `true`. Boot straight into Gaming Mode by owning the
login path with a greetd session loop. Cannot be combined with a regular
display manager (greetd aliases `display-manager.service`); in this repo the
adapter switches the `desktop` tag's display manager off automatically.

With `autoStart = false` the module only registers the "Steam" session:
pick it from your own display manager's session chooser; session *switching*
(which relies on the loop) is not available.

## `steamos.desktopSession`

Type `null or str`, default `null`, example `"gnome"`. The Wayland session
started by "Switch to Desktop" — a name from
`services.displayManager.sessionData.sessionNames` (the basename of a
`wayland-sessions/*.desktop` file). An unknown name is an eval-time error
listing the valid ones; `null` keeps you in Gaming Mode (with a warning).

The session itself must be enabled through your normal configuration
(`services.desktopManager.gnome.enable`, `plasma6.enable`, …) — this option
only selects it.

## Tuning Gaming Mode

Passed through to nixpkgs, not duplicated here:

| Option | Purpose |
|--------|---------|
| `programs.steam.gamescopeSession.args` | gamescope flags: output size, refresh, HDR, VRR, … |
| `programs.steam.gamescopeSession.env` | Environment for the session |
| `programs.steam.gamescopeSession.steamArgs` | Arguments for Steam itself. The module defaults these to the SteamOS set (`-gamepadui -steamos3 -steampal -steamdeck -pipewire-dmabuf`) — without `-steamos3`, overlay focus handling breaks (input-stranded "frozen" games) and the power menu lacks "Switch to Desktop" |
| `programs.steam.extraCompatPackages` | e.g. `proton-ge-bin` |
| `programs.gamescope.capSysNice` | Let gamescope renice itself. Known to be fragile with Steam's FHS environment — leave off unless you have verified it works. |
