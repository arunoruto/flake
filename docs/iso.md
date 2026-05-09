# Building ISOs for NixOS Hosts

This flake supports building bootable ISOs that embed the flake source, so `nixos-install --flake` works against `/etc/nixos/flake` without network access to the flake repo.

ISOs are generated from a single generic module (`systems/iso/installer.nix`) parameterized by hostname.

## Quick start

```bash
# Build an ISO for any registered host
nix build .#nixosConfigurations.iso-<hostname>.config.system.build.isoImage

# Write to USB
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

## Adding a new ISO target

Register it in `flake.nix` under `nixosConfigurations` with a single line:

```nix
nixosConfigurations =
  let
    mkIso = hostname: lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs self hostname; };
      modules = [ ./systems/iso/installer.nix ];
    };
  in
  import ./systems { ... } // {
    "iso-shinji"   = mkIso "shinji";
    "iso-kenpachi" = mkIso "kenpachi";
    "iso-zangetsu" = mkIso "zangetsu";
  };
```

The generic `installer.nix` module:
- Sets `isoImage.edition` = hostname (distinguishable filenames like `nixos-shinji-25.11-x86_64-linux.iso`)
- Embeds the flake source at `/nixos-flake` → copied to `/etc/nixos/flake` at boot
- Includes `disko` in the live Nix store
- Prints MOTD instructions referencing the hostname
- Provides an `autoinstall` systemd oneshot (triggers when `autoinstall` is in `/proc/cmdline`)

## Install workflow

### Manual (default)

1. Boot from USB
2. Login (root, no password)
3. Follow the on-screen instructions:

```bash
sudo disko --mode disko /etc/nixos/flake#<hostname>
sudo nixos-install --flake /etc/nixos/flake#<hostname> --root /mnt
sudo reboot
```

### Autoinstall

Add `autoinstall` to the kernel command line at boot:

1. In the GRUB menu, highlight the entry and press `e`
2. Append `autoinstall` to the `linux` line
3. Press `Ctrl+x` or `F10` to boot

The system will automatically partition the disk (via disko), install NixOS, and reboot.

## Example: shinji ISO

```bash
nix build .#nixosConfigurations.iso-shinji.config.system.build.isoImage
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

Boot the USB, then follow the printed instructions (or append `autoinstall` to the kernel cmdline). The shinji host uses a btrfs NVMe layout defined in `systems/x86_64-linux/shinji/disk.nix`.

## Prerequisites for a host to be ISO-installable

The target host must:

- Use **disko** for disk partitioning (`disk.nix` importing `inputs.disko.nixosModules.disko`)
- Have `fileSystems` in `hardware-configuration.nix` **commented out** — disko generates them declaratively
- Include the block device kernel module in `boot.initrd.availableKernelModules` (e.g. `"nvme"`, `"ahci"`, `"sd_mod"`)

## How it works

`systems/iso/installer.nix` receives `hostname` via `specialArgs` and uses it to:

- Set the ISO edition/volume label
- Populate MOTD instructions and autoinstall commands dynamically
- The flake source (`self`) is embedded as a raw copy on the ISO at `/nixos-flake`
- At boot, `postBootCommands` copies it to `/etc/nixos/flake` where `nixos-install --flake` can find it

## Size considerations

- The ISO includes the flake source closure, the live Nix store (squashfs), and disko
- Typical size: ~1.4 GB depending on extra `storeContents`
- Use `isoImage.squashfsCompression = "zstd -Xcompression-level 19"` (default) for best compression
- Add `isoImage.compressImage = true` for an extra `.zst` layer (slower build, smaller file)

## Generic minimal ISO

The flake also has a barebones ISO at `systems/iso/default.nix` that imports the standard `installation-cd-minimal` with `helix` added. Not registered as a nixosConfiguration — build it directly if needed.
