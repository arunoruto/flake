# Storage

## Filesystems at a glance

| FS | Use in this flake | Best for |
|---|---|---|
| **ext4** | the default root filesystem for most hosts | Simplicity, zero maintenance |
| **btrfs** | root on shinji, yhwach, kyuubi | Compression, snapshots |
| **zfs** | data pools only (sado, kuchiki) | Large storage, checksums |
| **vfat** | Every host with `/boot` (EFI) | EFI system partition |

## Host → filesystem mapping

| Host | Root | Data | Managed by |
|---|---|---|---|
| shinji | btrfs (`@root` + `@nix`) | — | disko |
| yhwach | btrfs (`subvol=@`) | — | hardware-config |
| kyuubi | btrfs (`subvol=@`) | — | hardware-config |
| sado | ext4 | zfs (`/mnt/flash`) | hardware-config |
| kuchiki | ext4 | zfs (`/mnt/storage`) | hardware-config |
| kenpachi | ext4 (LVM) | — | disko |
| aizen | ext4 (LVM) | — | disko |
| all others | ext4 | — | hardware-config |

## Choosing a filesystem for a new host

- **ext4** — the default. Simple, proven, zero configuration. Used on most hosts.
- **btrfs** — when you want transparent zstd compression (saves ~25% on `/nix/store`) or snapshot support. Use the `@root` + `@nix` subvolume layout to keep snapshots lightweight. See [btrfs.md](./btrfs.md) for details.
- **zfs** — only for dedicated data pools that benefit from checksums, dedup, or RAID-Z. Do not use for root: the out-of-tree kernel module frequently breaks on kernel updates.

## Disko

[Disko](https://github.com/nix-community/disko) provides declarative disk partitioning. Instead of manually running `fdisk`, `mkfs`, and recording UUIDs in `hardware-configuration.nix`, you define everything in a `disk.nix`:

- Partition layout (BIOS boot, ESP, root)
- Filesystem type (ext4, btrfs, zfs)
- Subvolume layout for btrfs
- LVM volumes if needed

Disko is imported per-host via `inputs.disko.nixosModules.disko` in the host's `disk.nix`. A few hosts use it (shinji, kenpachi, aizen); the rest use a manually-generated `hardware-configuration.nix` with explicit `fileSystems` entries.

When disko manages the filesystems, the `fileSystems` entries in `hardware-configuration.nix` should be **commented out** — disko generates them declaratively at build time.

### Example: shinji

```nix
# systems/x86_64-linux/shinji/default.nix
{ inputs, ... }: {
  imports = [
    ./configuration.nix
    ./disk.nix              # disko: btrfs on NVMe with @root + @nix subvolumes
    ./hardware-configuration.nix  # fileSystems commented out, disko handles them
  ];
}
```

See [btrfs.md](./btrfs.md) for a complete disko + btrfs walkthrough.
