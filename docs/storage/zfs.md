# ZFS on NixOS

## Why ZFS for data pools

| Feature | Benefit |
|---------|---------|
| **Checksums** | Detects and repairs bit rot on every read |
| **Snapshots** | Instant, zero-overhead point-in-time copies |
| **Dataset properties** | Compression, recordsize, etc. per dataset — no `chattr` hacks |
| **RAID-Z** | Redundancy without a hardware RAID controller |
| **Send/Receive** | Efficient backup and replication |

## Why NOT for root

- **Out-of-tree kernel module** — ZFS frequently breaks when the kernel updates. On NixOS with `boot.kernelPackages = linuxPackages_latest`, this is a recurring headache.
- **Boot complexity** — requires ZFSBootMenu or a separate `/boot` + manual pool import in initrd.
- **This flake's convention** — ext4 or btrfs for root, ZFS exclusively for data pools (`/mnt/flash`, `/mnt/storage`).

## Pool structure in this flake

### sado — `flash` pool

```
flash
├── flash/appdata       → /mnt/flash/appdata    (immich, paperless, komga configs)
├── flash/photos        → /mnt/flash/photos
├── flash/documents     → /mnt/flash/documents
└── flash/books         → /mnt/flash/books
```

Source: `systems/x86_64-linux/sado/hardware-configuration.nix`

### kuchiki — `storage` pool

```
storage
├── storage/appdata     → /mnt/storage/appdata   (media service configs)
├── storage/downloads   → /mnt/storage/downloads
└── storage/media       → /mnt/storage/media
```

Source: `systems/x86_64-linux/kuchiki/hardware-configuration.nix`

Both hosts use `hosts.zfs.enable = true` (shared module at `modules/nixos/system/zfs.nix`) and `systemd.services.zfs-mount.enable = false` (mount via NixOS `fileSystems` declarations instead).

## Creating a pool

### Single disk — no redundancy

```bash
zpool create tank /dev/sda
```

### Mirror — survives 1 disk failure

```bash
zpool create tank mirror /dev/sda /dev/sdb
```

Good for: root filesystem (if you must), appdata where uptime matters.

### RAID-Z — 1 disk parity, minimum 3 disks

```bash
zpool create tank raidz /dev/sda /dev/sdb /dev/sdc
```

Good for: media storage where capacity > performance.

### RAID-Z2 — 2 disk parity, minimum 4 disks

```bash
zpool create tank raidz2 /dev/sda /dev/sdb /dev/sdc /dev/sdd
```

Good for: large arrays where rebuild time is a concern.

### Ashift — always set for modern drives

4K sector drives (all SSDs and most HDDs since ~2011) need `ashift=12`:

```bash
zpool create -o ashift=12 tank mirror /dev/sda /dev/sdb
```

Without it: write amplification and performance degradation on 4K-native drives.

### Adding to NixOS config

After creating pools/datasets imperatively, declare them in `hardware-configuration.nix` so NixOS mounts them at boot:

```nix
fileSystems."/mnt/tank" = {
  device = "tank";
  fsType = "zfs";
};

fileSystems."/mnt/tank/media" = {
  device = "tank/media";
  fsType = "zfs";
};
```

## Datasets

### Creating

```bash
zfs create tank/appdata
zfs create tank/media

# Custom mountpoint
zfs create -o mountpoint=/custom/path tank/custom
```

### Recommended properties

| Property | Value | Why |
|----------|-------|-----|
| `compression` | `lz4` or `zstd` | Free space savings, negligible CPU cost. `lz4` for speed, `zstd` for higher compression. |
| `recordsize` | `1M` (media) / `128K` (general) / `16K` (databases) | Match workload I/O patterns. |
| `atime` | `off` | Eliminates metadata writes on every read access. |
| `xattr` | `sa` | Store extended attributes in dnodes instead of hidden files — big speedup. |
| `acltype` | `posix` | POSIX ACLs; enables `nfs4` if you need that. |
| `aclinherit` | `passthrough` | Inherit ACLs from parent if using ACLs. |
| `dedup` | `off` | Keep it off — RAM consumption is enormous. |

### Media dataset — large sequential files

```bash
zfs set compression=zstd recordsize=1M atime=off tank/media
```

### Appdata dataset — small random I/O (databases, configs)

```bash
zfs set compression=lz4 recordsize=128K atime=off xattr=sa tank/appdata
```

### Downloads dataset — mixed, discard-friendly

```bash
zfs set compression=zstd recordsize=1M atime=off tank/downloads
```

## Snapshots

### Manual

```bash
zfs snapshot tank/media@backup-$(date -I)
zfs list -t snapshot
```

### Automatic (zfs-auto-snapshot)

```nix
services.zfs.autoSnapshot = {
  enable = true;
  frequent = 4;   # keep 4 quarter-hourly snapshots
  hourly = 24;
  daily = 7;
  weekly = 4;
  monthly = 6;
};
```

### Rollback

```bash
zfs rollback tank/media@backup-2026-01-01

# For older snapshots (destroys intermediate snapshots):
zfs rollback -r tank/media@backup-2025-12-01
```

### Access files from a snapshot without rollback

Snapshots are mounted read-only under `/.zfs/snapshot/<name>/`:

```bash
ls /mnt/tank/media/.zfs/snapshot/backup-2026-01-01/
cp /mnt/tank/media/.zfs/snapshot/backup-2026-01-01/deleted-file.txt .
```

## Maintenance

### Scrubbing — data integrity check

```bash
zpool scrub tank
zpool status tank    # watch progress
```

This flake enables auto-scrub in `modules/nixos/system/zfs.nix`:

```nix
services.zfs.autoScrub = {
  enable = true;
  interval = "*-*-1,15 02:30";   # 1st and 15th of every month at 2:30 AM
};
```

### Pool and dataset status

```bash
zpool status              # health, errors, scrub progress
zpool list                # space per pool
zfs list                  # space per dataset
zfs list -t snapshot      # list all snapshots
zfs get all tank/appdata  # all properties of a dataset
```

### Replacing a failed disk

```bash
# After physically swapping the disk:
zpool replace tank /dev/sdb /dev/sdc
zpool status tank         # wait for resilver
```

### Destroying a pool

```bash
zpool destroy tank
# If pool claims to be busy:
zpool destroy -f tank
```

## Adding ZFS to a new host

1. Enable the shared ZFS module:

```nix
hosts.zfs.enable = true;
```

2. Set a host ID (required — pick a random hex string):

```nix
networking.hostId = "a1b2c3d4";
```

3. Disable automatic zfs-mount service (NixOS handles mounting via `fileSystems`):

```nix
systemd.services.zfs-mount.enable = false;
```

4. Declare datasets in `hardware-configuration.nix`:

```nix
fileSystems."/mnt/tank" = {
  device = "tank";
  fsType = "zfs";
};
fileSystems."/mnt/tank/appdata" = {
  device = "tank/appdata";
  fsType = "zfs";
};
```

See `systems/x86_64-linux/sado/` and `systems/x86_64-linux/kuchiki/` for working examples.
