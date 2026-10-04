# Testing

Steamix is tested with the [NixOS test driver](https://nixos.org/manual/nixos/unstable/#sec-nixos-tests):
each test boots a QEMU virtual machine built from a NixOS configuration that
imports the module, then drives it from a Python test script. The tests live
in `tests/`, one file per test.

| Test | What it covers |
|------|----------------|
| `greetd` | The default login path end to end. Boot lands in Gaming Mode; the gamescope command line and Steam's environment match the options; the session logs to the journal; the performance-overlay presets are generated; "Switch to Desktop" lands in the configured desktop session as a logind `class=user`, `type=wayland` session with its identity in the systemd user manager; "Return to Gaming Mode" goes back; a killed gamescope falls back to Gaming Mode. |
| `sddm` | The SteamOS-shaped login path. SDDM autologin lands in Gaming Mode; both SteamOS Manager daemons run and publish `SessionManagement1`; the session's stand-in unit is active and the configured desktop is the manager's default; "Switch to Desktop" and "Return to Gaming Mode" go through the manager (temporary autologin drop-in, `graphical-session.target` stopped, Steam shut down cleanly); a killed gamescope falls back to Gaming Mode and stays there; a temporary session left behind does not survive a reboot. |
| `steamos-manager` | SteamOS Manager finds the data it ships. A VM presenting a ROG Ally's DMI identity is recognised as one from the device configs; a VM with QEMU's own identity is `unknown` without an error, like a desktop PC; none of the Deck-only interfaces (factory reset, fan control, BIOS and dock updates, storage) appear on a PC; and nothing fails to read under `/usr/share/steamos-manager`. |
| `decky-loader` | The loader serves on port 1337; declared plugins are linked from the store and load (frontend-only ones as passive); backend plugins run as the unprivileged user; the CEF flag lands in the Steam user's home with every directory on the way owned by that user; a store-installed plugin coexists with declared ones; a declared plugin removed through the UI is back after a reboot. |

## Running them

The tests are the Steamix flake's own `checks`. From `steamix/`, against its
`nixos-unstable` input:

```sh
nix build -L .#checks.x86_64-linux.greetd
```

From the repository root, pinned to a nixpkgs the parent flake locks, which
is what CI does. `--inputs-from .` makes the parent's locked inputs
resolvable by name, so the override needs no revision:

```sh
nix build -L --no-write-lock-file --inputs-from . \
  --override-input nixpkgs nixpkgs ./steamix#checks.x86_64-linux.greetd

# the channel Steamix's own flake follows
nix build -L --no-write-lock-file --inputs-from . \
  --override-input nixpkgs nixpkgs-unstable ./steamix#checks.x86_64-linux.greetd
```

Nothing about the tests lives in the parent flake. When Steamix moves to its
own repository it commits its own lock file and the override goes away.

All of them need `/dev/kvm`; without it the driver falls back to emulation
and is many times slower. A test VM boots in about 15 seconds and each test
script runs in 20 to 45, so the cost of a run is almost entirely building the
VM's closure the first time.

To poke at a test machine by hand, build `.driverInteractive` and run the
driver; `start_all()` boots the VMs and every `machine.*` call from the test
script works at the prompt:

```sh
nix build ./steamix#checks.x86_64-linux.greetd.driverInteractive --no-write-lock-file
./result/bin/nixos-test-driver
```

The Steamix workflow runs every test against both channels, and only for
pushes that change something under `steamix/`, so unrelated work in the
repository never runs it; it can also be started by hand. A nixpkgs bump that
breaks Steamix therefore shows up on the next Steamix change or manual run.
The workflow's canonical copy is `steamix/.github/workflows/steamix.yaml`.
GitHub only loads regular files from the repository's root
`.github/workflows` and does not follow symlinks there, so the root file is a
byte-for-byte copy, and the workflow's first step fails if the two differ.

## What is real and what is not

Three things are replaced by stand-ins, defined in `tests/lib.nix`:

- **Steam** is unfree, downloads its client on first start and needs an
  account. The stub accepts Valve's arguments, records its environment, runs
  `steamos-session-select` the way the power menu does, and exits on
  `steam -shutdown`.
- **gamescope** needs a Vulkan device with a DRM render node for every
  backend, headless included. The only Vulkan driver in a sandboxed VM is
  lavapipe, which has none, so the real binary starts, selects llvmpipe and
  dies with "Failed to create backend". The stub records the command line the
  session script built and runs Steam as its child.
- **The desktop** is a script registered as a Wayland session, which records
  the identity and logind session it was given.

Everything between them is the real thing: greetd, the PAM stack, logind, the
launcher, the session script and the switcher. That is the part of Gaming
Mode this module owns. What the tests cannot see is gamescope's own
behaviour: mode selection, HDR, VRR and the overlay rendering need real
hardware.

## What they have caught

Every bug below was found by these tests, and none of them showed up on
the host that uses the module:

- **greetd's PAM stack changed shape on nixpkgs-unstable.** From 26.11 it is
  a single `include login`, and the identity rule was ordered after an inline
  `env` rule that no longer exists, so the greetd path failed to evaluate.
  The host uses the SDDM path and runs 26.05, so nothing evaluated it.
- **The CEF flag was never created on a fresh install.** The system
  tmpfiles instance created the missing `~/.local` as root, then refused to
  write through it, so Decky never appeared, and Steam's own first-run
  install into `~/.local/share/Steam` had nowhere to write. The host's Steam
  had created those directories long before Decky was enabled.
- **SteamOS Manager's user daemon crash-looped on a fresh install.** The
  module seeds its state file with the desktop session, but the seed lacked
  `default_login_mode`, which the 26.4.1 daemon requires, so the daemon
  exited at startup and took `SessionManagement1`, and with it "Switch to
  Desktop", along. The host's daemon had written its own state file before
  the seed existed, and the seed never overwrites one.
- **SteamOS Manager never recognised a handheld.** It reads its platform
  file and device configs from `/usr/share/steamos-manager`, and the package
  installed them into its store path, so every device lookup failed and the
  TDP, GPU and performance-profile controls the device configs describe
  never appeared. The package now points the daemon at its own data.
- **A crash in Gaming Mode on the SDDM path became a restart loop.** The
  next session replaced the stand-in unit the dead one had left. Stopping
  the old unit left `graphical-session.target` unneeded, systemd stopped it,
  and that stop took the new stand-in, and so the new Steam, down within a
  fraction of a second. SDDM relogged and the race repeated about twice a
  second, 117 times in the minute CI watched, until a reboot. It is timing
  dependent and only one CI run in several hit it, which is why both login
  tests now also check that the recovered session stays up.
