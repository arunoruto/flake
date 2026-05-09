# Maintainer Notes

## TODO

- Integrate [disko](https://github.com/nix-community/disko) for each host
- Manage host types via Colmena host tags for finer-grained control

## Fixes

### Thick black borders in GNOME apps

Set `GSK_RENDERER=gl`. Tracked at [GTK#6890](https://gitlab.gnome.org/GNOME/gtk/-/issues/6890#note_2232593).

## Credits

- [use-the-fork](https://github.com/use-the-fork) — help moving from standalone Home Manager to module-based setup
- [u/paulgdp](https://www.reddit.com/user/paulgdp/) — [advice](https://www.reddit.com/r/NixOS/comments/19c5een/comment/kiwxy8b/) on detecting `nixosConfig` in module context
- `olmokramer` — [example](https://discourse.nixos.org/t/flakes-how-to-automatically-set-machine-hostname-to-nixosconfiguration-name/45217/2) using `lib.genAttrs` for host generation
