# Building ISOs for NixOS Hosts

This flake supports building bootable ISOs that embed the flake source, so `nixos-install --flake` works against `/etc/nixos/flake` without network access to the flake repo.

## Quick start

```bash
# Build an ISO (replace <name> with the ISO target)
nix build .#nixosConfigurations.iso-<name>.config.system.build.isoImage

# Write to USB
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

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

## Adding a new ISO target

### 1. Create the ISO module

Place it at `systems/iso/<name>.nix`:

```nix
{ config, lib, pkgs, modulesPath, self, inputs, ... }:
let
  disko-pkg = inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko;
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  # Embed flake source on the ISO
  isoImage.contents = [
    {
      source = self;
      target = "/nixos-flake";
    }
  ];

  # Include disko in the live Nix store (no network needed to partition)
  isoImage.storeContents = [
    config.system.build.toplevel
    disko-pkg
  ];

  environment.systemPackages = [
    disko-pkg
    pkgs.git
    pkgs.helix
  ];

  # Copy flake to /etc/nixos at boot for nixos-install usage
  boot.postBootCommands = lib.mkAfter ''
    if [ ! -e /etc/nixos/flake ]; then
      cp -r /iso/nixos-flake /etc/nixos/flake
      chmod -R u+w /etc/nixos/flake
    fi
    if ! grep -q 'autoinstall' /proc/cmdline; then
      cat << 'HEREDOC' >> /etc/motd

=== <name> Installer ===
1. Partition:  sudo disko --mode disko /etc/nixos/flake#<hostname>
2. Install:    sudo nixos-install --flake /etc/nixos/flake#<hostname> --root /mnt
3. Reboot:     sudo reboot

Autoinstall:  reboot and add 'autoinstall' to kernel cmdline
===================
HEREDOC
    fi
  '';

  # Autoinstall service — only triggers when 'autoinstall' is in kernel cmdline
  systemd.services.autoinstall = {
    description = "Autoinstall NixOS from embedded flake";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig.Type = "oneshot";
    path = [
      disko-pkg
      pkgs.nixos-install-tools
      pkgs.coreutils
      pkgs.util-linux
    ];
    script = ''
      if grep -q 'autoinstall' /proc/cmdline; then
        echo "==> Autoinstall triggered: partitioning disk..."
        disko --mode disko /etc/nixos/flake#<hostname>
        echo "==> Installing NixOS..."
        nixos-install --flake /etc/nixos/flake#<hostname> --root /mnt --no-root-passwd
        echo "==> Done! Rebooting in 5s..."
        sleep 5
        reboot -f
      fi
    '';
  };
}
```

### 2. Register in `flake.nix`

```nix
nixosConfigurations = import ./systems { ... } // {
  "iso-<name>" = lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [ ./systems/iso/<name>.nix ];
  };
};
```

### 3. Build

```bash
nix build .#nixosConfigurations.iso-<name>.config.system.build.isoImage
```

## Example: shinji ISO

The shinji host uses a btrfs NVMe layout with two subvolumes (`@root` for `/`, `@nix` for `/nix`):

```bash
nix build .#nixosConfigurations.iso-shinji.config.system.build.isoImage
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

Boot the USB, then follow the printed instructions (or append `autoinstall` to the kernel cmdline).

Source files:
- `systems/iso/shinji.nix` — ISO module
- `systems/x86_64-linux/shinji/disk.nix` — btrfs disko layout

## Prerequisites for a host to be ISO-installable

The target host must:

- Use **disko** for disk partitioning (`disk.nix` importing `inputs.disko.nixosModules.disko`)
- Have `fileSystems` in `hardware-configuration.nix` **commented out** — disko generates them declaratively
- Include the block device kernel module in `boot.initrd.availableKernelModules` (e.g. `"nvme"`, `"ahci"`, `"sd_mod"`)

## Size considerations

- The ISO includes the flake source closure, the live Nix store (squashfs), and disko
- Typical size: 1-2 GB depending on extra `storeContents`
- Use `isoImage.squashfsCompression = "zstd -Xcompression-level 19"` (default) for best compression
- Add `isoImage.compressImage = true` for an extra `.zst` layer (slower build, smaller file)

## Generic minimal ISO

The flake also has a barebones ISO at `systems/iso/default.nix` that imports the standard `installation-cd-minimal` with `helix` added. Not registered as a nixosConfiguration — build it directly if needed.
