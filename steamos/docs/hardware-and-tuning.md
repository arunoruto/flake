# Hardware setup & tuning

The module gets you *into* Gaming Mode; how well it runs is decided by the
hardware configuration around it. Nothing here is steamos-specific machinery —
it is the checklist of things worth setting up by hand until someone figures
out how to automate them. Like the rest of these pages it is written
split-ready: when `steamos.nix` becomes its own repository, this guide moves
with it.

## nixos-facter: describe the hardware as data

[nixos-facter](https://github.com/numtide/nixos-facter) is the modern take on
`nixos-generate-config`'s hardware detection. Instead of generating a Nix file
once and letting it rot, it writes a JSON *report* of everything it probes —
CPU, GPU, buses, network interfaces, bluetooth, disks — and the companion
[nixos-facter-modules](https://github.com/numtide/nixos-facter-modules)
interpret that report at evaluation time.

Why bother, when `hardware-configuration.nix` exists?

- **The report is data, the interpretation is code.** When the modules learn a
  better way to configure some device class, every host with a report picks it
  up on the next rebuild — a generated `hardware-configuration.nix` never
  improves after the day it was written.
- **It sees more**: firmware/microcode, graphics stacks (Mesa, 32-bit support),
  bluetooth, virtualisation guests — not just kernel modules and filesystems.
- **It is reviewable**: a hardware swap shows up as a readable diff of the
  report, checked in next to the host.

Generate (or refresh) a report on the machine itself:

```sh
sudo nix run \
  --option experimental-features "nix-command flakes" \
  nixpkgs#nixos-facter -- -o facter.json
```

Then wire it in:

```nix
# outside this repo:
imports = [ inputs.nixos-facter-modules.nixosModules.facter ];
facter.reportPath = ./facter.json;
```

In this repo, just drop `facter.json` into `systems/<arch>/<host>/` — it is
picked up automatically.

**Re-run it after every hardware change.** A stale report is silently wrong:
when yhwach's GTX 1060 made way for the RX 9060 XT, the old report kept
describing the nvidia card, and AMD-specific extras gated on detection (like
`hardware.amdgpu.opencl` in this repo's `hosts.amd.gpu` module) stayed off
until the report was regenerated.

## nixos-hardware: quirks other people already debugged

[nixos-hardware](https://github.com/NixOS/nixos-hardware) is a community
collection of per-device and per-component modules — the accumulated "this
machine needs that kernel parameter" knowledge, packaged. If facter describes
*what* hardware you have, nixos-hardware fixes *how* it behaves. When the
steamos repo split happens, a guide like this one definitely belongs in it.

Add the input, then import either a **named machine profile** (best case:
someone with your exact machine already did the work):

```nix
inputs.nixos-hardware.url = "github:nixos/nixos-hardware";

imports = [ inputs.nixos-hardware.nixosModules.framework-13-7040-amd ];
```

…or compose from the **generic building blocks** under `common/` when there is
no profile for your machine. That is what yhwach does:

```nix
imports = [
  (inputs.nixos-hardware.outPath + "/common/cpu/intel/coffee-lake")
  (inputs.nixos-hardware.outPath + "/common/gpu/amd")
];
```

Blocks worth knowing for a Steam machine:

| Import | What it buys you |
|--------|------------------|
| `common/gpu/amd` | amdgpu driver stack incl. early KMS — flicker-free boot into gamescope |
| `common/cpu/amd/pstate`, `common/cpu/intel` | modern CPU frequency scaling / microcode |
| `common/pc/ssd` | periodic TRIM |
| `common/pc/laptop` | power tuning, if the "console" is a laptop |

Browse the repo's `common/` tree — the modules are tiny and readable, so when
in doubt, read what an import actually sets before adopting it.

## Getting the most out of Gaming Mode

Everything below is upstream nixpkgs options — listed here because finding
them is the hard part.

**Match gamescope to your display.** By default gamescope picks something
sensible; being explicit avoids surprises on TVs. One list element per argv
entry:

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

HDR and VRR are not in that list because `steamos.hdr.enable` and
`steamos.vrr.enable` are on by default — they pass the gamescope flag *and*
tell Steam the session supports the feature, which is what puts the toggles in
Gaming Mode's display settings.

**A new GPU wants a new kernel.** Release-branch LTS kernels lag GPU support
by months (RDNA 4 is the current example):

```nix
boot.kernelPackages = pkgs.linuxPackages_latest;
```

**Proton-GE** fixes titles that stock Proton struggles with:

```nix
programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];
```

(In this repo the `gaming` tag already adds this from `pkgs.unstable`.)

**Controllers.** `programs.steam` enables `hardware.steam-hardware` (udev
rules for every controller Steam supports) by itself. On top of that:

```nix
hardware.bluetooth.enable = true;   # BT gamepads
hardware.xpadneo.enable = true;     # better Xbox-controller-over-BT driver
```

**Feels-faster knobs:**

```nix
programs.gamemode.enable = true;    # CPU governor/niceness while a game runs
zramSwap.enable = true;             # compressed-RAM swap; no disk partition needed
```

MangoHud is available too (`MANGOHUD=1` in a game's launch options after
adding `pkgs.mangohud`), though Gaming Mode's built-in performance overlay
covers most of it.

## Good to know

- **Audio** must be configured by you (the module does not assume a sound
  stack): `services.pipewire.enable` plus its `alsa`/`pulse` sub-options is
  the standard choice. In this repo the `desktop` tag handles it.
- **First boot lands in Steam's login screen** — initial setup (account,
  network if NetworkManager is present) happens inside the Deck UI itself.
- **Firewall**: `programs.steam.remotePlay.openFirewall` and
  `localNetworkGameTransfers.openFirewall` open what Remote Play / local game
  transfers need.
- **Failsafe**: if a driver or session change ever leaves the machine
  crash-looping into a black screen, switch to another VT
  (Ctrl+Alt+F2), log in, and roll back — the loop never blocks a text
  console. See [known limitations](./how-it-works.md#known-limitations).
- **Updates**: Gaming Mode's own "check for updates" updates games, not the
  OS — system updates stay `nixos-rebuild` / your deploy tool. SteamOS-style
  atomic OS updates are exactly what NixOS generations already are.

## Machines with two GPUs

A desktop with a discrete card *and* an active integrated one (any Intel or AMD
CPU with video output enabled in firmware) has a trap waiting: nothing pins
which GPU gamescope composites on. It selects a Vulkan device, then opens the
DRM node that matches it — and which card that turns out to be depends on
kernel enumeration order, which is not stable across boots. The same machine
can come up on the discrete card for weeks and then, one boot, land on the
iGPU, open a DRM node with no connected output, fail to create a backend, and
leave you at a black screen with greetd looping until it hits its restart
limit.

Pin it by PCI ID:

```nix
steamos.gamescope.args = [
  "--prefer-vk-device"
  "1002:7590"   # `lspci -nn | grep -i vga`, or /sys/class/drm/card*/device/{vendor,device}
];
```

`gamescope --steam ... 2>&1 | grep 'selecting physical device'` confirms the
choice; it names the card it settled on.
