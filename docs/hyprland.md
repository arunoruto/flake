# Hyprland

Hyprland is wired up but **not enabled on any host**. A host opts in with a
single line in its `configuration.nix`:

```nix
programs.hyprland.enable = true;
```

That is the NixOS module (`modules/nixos/desktop/hyprland.nix`). It provides
the session entry for the display manager, the `cap_sys_nice` wrapper, the
portal and — via `withUWSM` — the systemd session units. The home-manager side
follows it automatically (`osConfig.programs.hyprland.enable`), the same way
niri does, so there is no second toggle to remember.

## Lua, not hyprlang

Since **0.55** the config file is `~/.config/hypr/hyprland.lua` and every
setting is a call into a global `hl` table. hyprlang (`hyprland.conf`) still
loads, but it is the legacy path and the wiki no longer documents it.

home-manager renders `wayland.windowManager.hyprland.settings` accordingly —
each attribute becomes an `hl.<name>(...)` call:

| Nix                                           | Lua                              |
| --------------------------------------------- | -------------------------------- |
| `settings.config = { general.gaps_in = 3; }`   | `hl.config({ general = { … } })`  |
| `settings.monitor = [ { output = "DP-1"; } ]`  | one `hl.monitor({ … })` per entry |
| `settings.x._args = [ a b ]`                   | `hl.x(a, b)`                      |
| `settings.x._var = "SUPER"`                    | `local x = "SUPER"`               |
| `lib.generators.mkLuaInline "hl.dsp.foo()"`    | raw Lua, unquoted                 |

`home.stateVersion` here is 23.05, so `configType = "lua"` is set explicitly in
the module — home-manager only defaults to Lua from stateVersion 26.05 on.

Everything lands in `modules/home-manager/foreground/desktop/hyprland/`:

| File         | What it owns                                        | Applies when                          |
| ------------ | --------------------------------------------------- | ------------------------------------- |
| `default.nix`| compositor settings, session plumbing, must-haves    | `wayland.windowManager.hyprland.enable` |
| `binds.nix`  | every keybind, plus the `resize` submap              | `wayland.windowManager.hyprland.enable` |
| `lock.nix`   | hyprlock                                            | `programs.hyprlock.enable`            |
| `idle.nix`   | hypridle                                            | `services.hypridle.enable`            |
| `paper.nix`  | hyprpaper (stylix drives the wallpaper)              | `services.hyprpaper.enable`           |

There are no custom toggles: each file attaches to home-manager's own switch,
and `default.nix` turns those on. To drop a piece on one host, turn its
upstream switch off (e.g. `services.hypridle.enable = false;`).

## Binds

`hl.bind(keys, dispatcher, { flags })`. The old `bind` suffixes are flags now:

| Old      | Now                    |
| -------- | ---------------------- |
| `bindm`  | `{ mouse = true; }`    |
| `binde`  | `{ repeating = true; }`|
| `bindl`  | `{ locked = true; }`   |
| `bindr`  | `{ release = true; }`  |
| `bindd`  | `{ description = "…"; }`|

Also available: `long_press`, `click`, `drag`, `non_consuming`,
`auto_consuming`, `transparent`, `ignore_mods`, `submap_universal`,
`dont_inhibit`, `device`.

`binds.nix` wraps that in a `bind` helper, so adding one is a line:

```nix
(bind "${mod} + N" (exec "obsidian") { description = "Notes"; })
(bind "${mod} + X" "hl.dsp.window.kill()" { description = "Kill window"; })
```

`exec` wraps `hl.dsp.exec_cmd` (which runs through `sh -c`), and a bare string
is raw Lua. Dispatchers live under `hl.dsp.*`; the renames worth knowing:

| Old dispatcher        | New                                        |
| --------------------- | ------------------------------------------ |
| `killactive`          | `hl.dsp.window.close()`                     |
| `movefocus, l`        | `hl.dsp.focus({ direction = "left" })`      |
| `movewindow, l`       | `hl.dsp.window.move({ direction = "left" })`|
| `movetoworkspace, 3`  | `hl.dsp.window.move({ workspace = 3 })`     |
| `workspace, e+1`      | `hl.dsp.focus({ workspace = "e+1" })`       |
| `togglefloating`      | `hl.dsp.window.float()`                     |
| `togglegroup`         | `hl.dsp.group.toggle()`                     |
| `exit`                | `uwsm stop` (see below)                     |

Descriptions are worth setting: `hyprctl binds` prints them, which beats
grepping the generated Lua. `hyprctl dispatch` also takes Lua now:

```sh
hyprctl dispatch 'hl.dsp.submap("reset")'
hyprctl repl                      # interactive Lua against the live compositor
```

### Current bindings

`SUPER` throughout (the `mod` binding at the top of `binds.nix`).

| Keys                        | Action                                  |
| --------------------------- | --------------------------------------- |
| `Return` / `D` / `F1`       | terminal / launcher / browser           |
| `SHIFT+Q`                   | close window                            |
| `SPACE` / `F` / `P` / `C`   | float / fullscreen / pseudotile / center|
| `H J K L` (or arrows)       | focus                                   |
| `SHIFT` + those             | move window                             |
| `1`–`0`                     | workspace; with `SHIFT`, move window there |
| `S` / `SHIFT+S`             | scratchpad toggle / move there          |
| `G` / `Tab` / `SHIFT+Tab`   | tab group toggle / next / previous      |
| `V`                         | flip dwindle split                      |
| `R`                         | resize submap (`escape` leaves)         |
| `SHIFT+R` / `SHIFT+E`       | reload config / exit session            |
| `ALT+L`                     | lock (`loginctl lock-session`)          |
| `Print`, `SHIFT+`, `SUPER+` | screenshot region / window / output     |
| media & brightness keys     | wpctl, playerctl, brightnessctl         |

### Submaps

A submap is a second keymap, live only while active:

```nix
submaps.resize.settings.bind = [
  (bind "L" "hl.dsp.window.resize({ x = 40, y = 0, relative = true })" { repeating = true; })
  (bind "escape" ''hl.dsp.submap("reset")'' { })
];
```

`onDispatch = "reset"` drops out after a single key. Always leave yourself a
way back — `hyprctl dispatch 'hl.dsp.submap("reset")'` from a TTY if not.

## Session management (uwsm)

`withUWSM = true` is the default here, so the display manager shows
**"Hyprland (uwsm-managed)"**. uwsm wraps the compositor in real systemd units,
which means:

- `wayland.windowManager.hyprland.systemd.enable` is **off** — the
  home-manager `hyprland-session.target` would race uwsm's own units. Services
  bind to `graphical-session.target` instead.
- Do not exit with the `exit` dispatcher; it yanks the compositor out from
  under its clients. `SUPER+SHIFT+E` runs `uwsm stop`.
- Session-wide environment variables belong in `~/.config/uwsm/env`
  (`HYPR*`/`AQ_*` in `env-hyprland`), not in the compositor config. The module
  already points `uwsm/env` at home-manager's session variables.
- Autostart is systemd, not `exec-once`: `systemctl --user enable <unit>`.

## Monitors and workspaces

Per host, in the host's `home.nix`:

```nix
wayland.windowManager.hyprland.settings = {
  monitor = [
    { output = "DP-1"; mode = "1920x1080"; position = "0x0"; scale = 1; }
  ];
  workspace_rule = [
    { workspace = "1"; monitor = "DP-1"; default = true; }
  ];
};
```

An empty `output` is the fallback rule for every monitor without one of its
own; that is what the module ships as a `mkDefault`. `hyprctl monitors all`
lists connectors and modes.

> Note: `systems/<arch>/<host>/home.nix` is **not** imported by anything today.
> Wire it in per host with
> `home-manager.sharedModules = [ ./home.nix ];` (watch out: madara's also
> deploys `~/.config/monitors.xml`, which GNOME otherwise manages itself).

## Plugins

Plugins are `.so` files loaded into the compositor, version-matched to it.
`hyprpm` is unsupported on NixOS; use the packaged ones:

```nix
wayland.windowManager.hyprland.plugins = [ pkgs.hyprlandPlugins.hy3 ];
```

Nothing is loaded by default. 0.55 has native groups and tabs
(`hl.dsp.group.*`) and a built-in scrolling layout, which covers most of what
hy3 and hyprscroller were for. Plugins that do expose dispatchers hang them off
`hl.plugin.<name>` in the Lua config:

```nix
(bind "${mod} + T" ''hl.plugin.hy3.make_group("tab")'' { })
```

## Ecosystem

Enabled with the session: **hyprlock** (PAM stack comes from the NixOS module —
without it, unlocking silently falls back to `su`), **hypridle**,
**hyprpaper**, **hyprpolkitagent**, **mako**, **wofi**, plus `hyprshot`,
`hyprpicker` and `brightnessctl` on `PATH`.

Not enabled, but packaged if you want them: `waybar` (a config already exists
in `bars/waybar` and applies whenever `programs.waybar.enable` is on), the quickshell-based
shells `caelestia-shell` / `noctalia-shell` / `dms`, `hyprpanel`,
`hyprlauncher`, `hyprsunset`, `hyprshell`, `cliphist`, `wlogout`.
