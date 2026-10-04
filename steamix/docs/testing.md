# Testing

Steamix is tested with the [NixOS test driver](https://nixos.org/manual/nixos/unstable/#sec-nixos-tests):
each test boots a QEMU virtual machine built from a NixOS configuration that
imports the module, then drives it from a Python test script. The tests live
in `tests/`, one file per test.

| Test | What it covers |
|------|----------------|
| `greetd` | The default login path end to end. Boot lands in Gaming Mode; the gamescope command line and Steam's environment match the options; the session logs to the journal; the performance-overlay presets are generated; "Switch to Desktop" lands in the configured desktop session as a logind `class=user`, `type=wayland` session with its identity in the systemd user manager; "Return to Gaming Mode" goes back; a killed gamescope falls back to Gaming Mode. |
| `decky-loader` | The loader serves on port 1337; declared plugins are linked from the store and load (frontend-only ones as passive); backend plugins run as the unprivileged user; the CEF flag lands in the Steam user's home with every directory on the way owned by that user; a store-installed plugin coexists with declared ones; a declared plugin removed through the UI is back after a reboot. |

## Running them

From the parent repository, against either nixpkgs it pins:

```sh
nix build -L .#steamix-tests.stable.greetd        # the nixpkgs the hosts run
nix build -L .#steamix-tests.unstable.greetd      # what Steamix's own flake follows
```

From `steamix/` on its own, against its `nixos-unstable` input:

```sh
nix build -L .#checks.x86_64-linux.greetd
```

Both need `/dev/kvm`; without it the driver falls back to emulation and is
many times slower. A test VM boots in about 15 seconds and each test script
runs in about 20, so the cost of a run is almost entirely building the VM's
closure the first time.

To poke at a test machine by hand, build `.driverInteractive` and run the
driver; `start_all()` boots the VMs and every `machine.*` call from the test
script works at the prompt:

```sh
nix build .#steamix-tests.stable.greetd.driverInteractive
./result/bin/nixos-test-driver
```

The Steamix workflow (`.github/workflows/steamix.yaml`) runs both tests
against both channels on every change under `steamix/`, on every lock file
change, and after each nightly lock update.

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

Both bugs below were found by these tests on their first run, and neither
showed up on the host that uses the module:

- **greetd's PAM stack changed shape on nixpkgs-unstable.** From 26.11 it is
  a single `include login`, and the identity rule was ordered after an inline
  `env` rule that no longer exists, so the greetd path failed to evaluate.
  The host uses the SDDM path and runs 26.05, so nothing evaluated it.
- **The CEF flag was never created on a fresh install.** The system
  tmpfiles instance created the missing `~/.local` as root, then refused to
  write through it, so Decky never appeared, and Steam's own first-run
  install into `~/.local/share/Steam` had nowhere to write. The host's Steam
  had created those directories long before Decky was enabled.
