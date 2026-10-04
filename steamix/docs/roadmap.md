# Roadmap

Where this project is going, and why. The module today gets a PC *into*
Gaming Mode and back out again; the pages before this one describe that
mechanism. This page is the list of things that would make it a console
rather than a desktop that happens to boot into Steam — written down so the
order is deliberate and the reasoning survives.

## Positioning

The comparison that matters is not Jovian-NixOS, it is
[Bazzite](https://bazzite.gg). Jovian answers "run Valve's stack on a Steam
Deck". Bazzite answers "a console OS for any PC and any handheld", and its
feature list — Decky, Heroic, emulators, a settings UI, handheld daemons — is
the one this project is reaching for.

What Bazzite cannot offer is what NixOS gives for free:

- the user *owns* the configuration, and a change survives the next update
  (install Tailscale on SteamOS and it is gone after the next reboot);
- every update is a generation, so rolling back is picking a different one;
- features compose from data, so "enable Decky" is one line and the plugins
  it loads are a list.

Everything below is chosen to sharpen that argument. The target is a project
feature-rich enough to present at NixCon 2027.

## Make it a console

These are the pieces that turn "NixOS with a Steam session" into something a
non-Nix user can live with. They are also the strongest demo material.

### OS updates from Gaming Mode

Steam's "Check for updates" button in Gaming Mode runs an executable named
`steamos-update`. The contract is small: `steamos-update check` exits `0`
when an update is available and `7` when the system is up to date, and the
real run prints progress percentages that the client (and KDE Discover's
SteamOS backend) renders. Jovian stubs it to "nothing to do".

Implement it for real:

1. fetch the configured flake ref;
2. build the toplevel and compare it against the running system — identical
   store path means exit `7`;
3. `nixos-rebuild switch` with progress lines on stdout, so the Deck UI shows
   a bar instead of a spinner.

SteamOS branches map onto flake refs, so `steamos-select-branch` becomes
stable / unstable / your fork. This is the single feature that demonstrates
the whole pitch: an update applied from the Deck UI, then a rollback.

### Automatic rollback on a broken boot

[How it works](./how-it-works.md#known-limitations) lists "no crash-loop
brake" as a known limitation. NixOS has boot counting through
`boot.uki.tries`: systemd-boot marks an entry bad after N failed attempts and
falls back to the previous generation. Pair it with a session watchdog — the
greetd loop or SDDM relogin failing a few times in a row counts the boot as
failed — and a bad gamescope or driver update heals itself. This is SteamOS'
A/B slot fallback, built from generations.

### A binary cache

Handhelds should never compile gamescope, steamos-manager or Decky. The
project wants its own Cachix cache and a CI job that builds every package
against nixpkgs-unstable, so a fresh install is a download, not a build.

### An installer that creates the user's repository

The audience this is for never writes Nix. The installer image should
generate a template flake with a `settings.json`, commit it locally, and
from then on the GUI (below) edits that file. Nobody opens a `.nix` file
unless they want to. The per-host ISO machinery already exists in the parent
repository; this is the standalone, user-facing version of it.

## Modules worth adding

Each of these fits the current shape: plain `pkgs`, plain `lib`, upstream
NixOS options, policy left to the consumer.

### Hardware from the facter report

The [two-GPU trap](./hardware-and-tuning.md#machines-with-two-gpus) is the
strongest case. A facter report lists every graphics card with PCI vendor
and device IDs, so the module can derive `--prefer-vk-device` and
`steamix.mangoapp.pciDev` for the discrete card by default, and only ask the
user when the report is absent or ambiguous. The same idea covers picking
`linuxPackages_latest` for a GPU the LTS kernel does not know yet. This is
how the project beats Jovian on generic hardware without writing per-device
modules.

### Handhelds

nixpkgs has `services.handheld-daemon` with its TDP adjustor and UI. A
`steamix.handheld.enable` switch that turns it on, adds the hhd Decky plugin
to `steamix.decky-loader.plugins`, and handles the power button covers the
ROG Ally, Legion Go and Ayaneo crowd — Bazzite's core audience.

### Mods as Steam compatibility tools

The clean home for modding software such as ModEngine3 for FromSoftware
titles. Steam's compatibility-tool dropdown is a first-class extension
point, and `programs.steam.extraCompatPackages` already feeds it. A wrapper
tool — "Proton-GE + ModEngine3" — means the user picks it per game in Gaming
Mode, and the mod list for a game is a generated ModEngine TOML. No writing
into Steam's own VDF files, which is where every other approach gets fragile.

### Launchers and emulators as library entries

Heroic, Lutris and ES-DE are only useful in Gaming Mode if they appear in the
library. A small `shortcuts.vdf` writer that adds declared entries and leaves
user-added ones alone gives `steamix.launchers.heroic.enable` that feels
native. Emulation is where Nix shines: `retroarch.withCores` plus declared
BIOS and ROM paths is EmuDeck without the installer script.

### Streaming and scheduler

Cheap wins on top of upstream options:

- `services.sunshine` needs only session wiring and the capture capability to
  stream Gaming Mode to Moonlight clients;
- `services.scx` with `scx_lavd` is the gaming scheduler Bazzite and CachyOS
  advertise, and here it is one option.

### Upstream the session

The gamescope session in `gaming-mode.nix` fixes real bugs in nixpkgs'
`programs.steam.gamescopeSession`: the second Xwayland server, the WSI layer,
the capability flags, the mangoapp config path. Send that upstream, together
with the `decky-loader` and `steamos-manager` packages and the
`buildDeckyPlugin` helper. It removes the `pkgs.decky-loader or null` dance
from the module and gives everyone else the fixes.

### VM tests

Started (2026-10-04): the `greetd`, `sddm` and `decky-loader` tests boot the
module in a VM and drive it end to end, against both nixpkgs channels, in CI.
See [Testing](./testing.md). They found three bugs on their first runs that
the host using the module never showed.

Still to cover: the updater and rollback once they exist. A test that runs
the real gamescope would need a Vulkan device with a DRM render node inside
the VM, which today means virtio-gpu with Venus and a host GPU — out of reach
for sandboxed builds.

## The GUI

Many people are afraid of editing a config file, and a typo in one is a bad
first experience. Most settings are a checkbox (enable a module), some are a
pick from a list (an enum), and only rarely does anyone need to type a value.

**The module is the GUI schema.** The option reference is already generated
from the module; the same options JSON carries type, default, description
and enum values, so a form can be rendered from it:

| Option type | Widget |
|-------------|--------|
| `bool` | checkbox |
| `enum` | dropdown |
| `str`, `int`, `float` | text field |
| `listOf package` | multi-select from a known set (e.g. `deckyPlugins`) |

Mark which options are user-facing with a small allowlist rather than
exposing all of them.

**The GUI never writes Nix.** It writes `settings.json`, commits it to the
local repository, and triggers the same update path as the Gaming Mode
button. A bad change is a generation to roll back from, not a broken file to
debug. The module reads the file with `lib.importJSON` and treats it as
ordinary configuration.

**A Decky plugin is the right first frontend.** It renders inside the Deck
UI, so it feels native, and the loader already runs as root, so it can
trigger the rebuild. A later `steamos-manager`-style D-Bus service with a
polkit rule is the cleaner shape once the flow works.

## nixos-hardware and facter

An idea discussed with the facter maintainer at NixCon: expose common
nixos-hardware tuning (CPU, GPU) as options instead of imports, so facter
could switch them on. Their answer was that facter's own modules already
derive most of what is *present*.

What nothing derives is the tuning in nixos-hardware's `common/` tree:
amd-pstate, per-generation Intel media stacks, fstrim, laptop power. The
parent repository solves that in `systems/hardware-profiles.nix`, which maps
CPU model and GPU driver from the report to profile directories. The obstacle
it documents is real: those profiles carry nested `imports`, so the choice
cannot depend on `config`, which is why "expose them as options" is the wrong
PR.

The PR that would land is a facter entrypoint in nixos-hardware itself: a
function that takes a report path and returns the profile list, built from
that mapping table. Propose it as a function first; the option form can
follow if the profiles are ever flattened.

## ARM devices

NixOS runs on aarch64 as well as it runs on x86_64, and the hardware is
arriving: Snapdragon handhelds (AYN Odin and Thor, Retroid Pocket, AYANEO
Pocket), and Valve's own ARM64 Steam client, built for the Steam Frame.
Steamix assumes x86_64 today only because Steam does.

### Prior art: Armada OS

[Armada OS](https://github.com/armada-os/armada) gets Gaming Mode running on
Snapdragon handhelds. It is a Fedora bootc image with device support from
ROCKNIX, created in mid-2026 and calling itself prototype software. Its
approach is the one to copy:

- **Steam is native, not emulated.** It runs Valve's ARM64 client, the
  `steamdeck_publicbeta` `linuxarm64` channel, with Valve's ARM64 Steam
  runtime. The image pre-bootstraps both offline and launches the ARM64
  binary directly; there is no 32-bit client anywhere
  ([steam-bootstrap](https://github.com/armada-os/armada/tree/main/packages/steam-bootstrap)).
- **Windows games use Valve's ARM64 Proton**, served through Steam, with
  Wine ARM64EC and FEX inside it. A CachyOS ARM64 Proton is the fallback.
- **FEX only runs x86 Linux code:** native x86 games and helpers that only
  exist as x86 binaries. It runs on the official FEX Arch root filesystem,
  with thunks for Vulkan, GL and Wayland, and per-game FEX profiles. An x86
  build of Mesa's Turnip driver is overlaid into that root filesystem.
  Box64 is not used.
- **The session is the shape Steamix's SDDM path already has:** SDDM
  autologin with relogin, the `holo.conf` marker so SteamOS Manager owns
  switching, `steamosctl` behind `steamos-session-select`, and the
  `gamescope-wayland` alias. Steam runs with the same
  `-gamepadui -steamos3 -steampal -steamdeck` flags.
- **The hard part is the hardware:** a mainline kernel with Snapdragon
  patches and 4K pages, Mesa with Turnip patches for the Adreno GPUs, about
  25 gamescope patches for EDID-less panels and the msm display driver, and
  Valve's Steam Frame patch series for SteamOS Manager, which teaches it
  devfreq GPUs and devices without DMI data.

### What Steamix would need

1. **A FEX module.** nixpkgs packages `fex` for aarch64 but has no NixOS
   module: no binfmt registration for x86 and x86_64, no FEXServer, no root
   filesystem. A `programs.fex` with `boot.binfmt.registrations`, a pinned
   root filesystem image and thunk configuration is useful far beyond
   Steamix, so it belongs upstream in nixpkgs, and it is the right first
   step.
2. **An aarch64 Steam.** nixpkgs' `steam` is x86-only. An ARM64 path would
   fetch Valve's `linuxarm64` client manifest and the ARM64 runtime and run
   them in an FHS environment, the way the x86 package runs its bootstrap.
3. **Device support stays outside Steamix.** Kernel, Mesa and gamescope
   patches for a given SoC are hardware enablement, which belongs in
   nixos-hardware profiles or the consumer's configuration. Steamix only
   needs its package options to accept the patched builds, which they
   already do.
4. **SteamOS Manager with the Steam Frame patches**, so TDP and GPU controls
   work on devices that are not x86 PCs.
5. **Decky runs natively.** Armada runs Decky's x86 PyInstaller binary
   under FEX. Steamix builds Decky from source as a Python package, so it
   should build for aarch64 as it is, with no emulation in the loop.
6. **VM tests on aarch64.** The tests are architecture-neutral apart from
   their x86 assumptions about Steam; with the stubs they could run on an
   aarch64 builder, which needs a runner with KVM.

### Blockers

- **Nothing stable to pin.** The ARM64 client lives on a public-beta
  channel with no stable URL or version. Armada pins a manifest and
  pre-bootstraps it; a Nix package would have to do the same and accept
  that Valve can withdraw a version.
- **Valve's FEX tooling assumes an FHS layout.** Steam's FEX compatibility
  tool hardcodes paths such as `/usr/share/guestos/fex-mesa`, which an FHS
  environment or a bind mount has to provide.
- **Page size.** FEX needs 4K pages, which rules out Asahi's default 16K
  kernel without a micro-VM such as `muvm`.

This is a direction for after the console pieces, not before. The FEX
module can start any time and stands on its own. "The same module on an ARM
handheld" would make a strong closing slide.

## Order of work

1. **The update button with rollback**, **the facter-driven GPU pin**, and
   **the compat-tool mod wrapper**. Each is a weekend of work, each is
   demoable on stage, and together they make the "your machine, still a
   console" argument.
2. **The settings file**, because it is the contract the GUI needs.
3. **The GUI**, as a Decky plugin.
4. Handhelds, launchers, emulation, streaming — the breadth that makes the
   project worth switching to.
5. Upstreaming and the VM tests, throughout, whenever a piece stabilises.
6. **ARM**, starting with a FEX module for nixpkgs, once the console pieces
   stand.
