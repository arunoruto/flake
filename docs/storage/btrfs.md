# Btrfs on NixOS

## Why btrfs

| Feature | Benefit on NixOS |
|---------|-----------------|
| **zstd compression** | 20-30% space saved on `/nix/store` transparently |
| **Subvolumes** | Separate `/` and `/nix` — snapshot root without bloating snapshots with store data |
| **Snapshots** | Roll back a bad `nixos-rebuild` in seconds |
| **Native kernel** | No out-of-tree module — works on every kernel update (unlike ZFS) |

Compared to ext4: same simplicity, more features. Compared to ZFS: fewer features but zero maintenance overhead.

## Layout used in this flake

Two subvolumes on a single btrfs partition:

```
/dev/<disk> (btrfs)
├── @root  → /        compress=zstd
└── @nix   → /nix     compress=zstd,noatime
```

- **`@root`**: the OS, your home, `/etc` — everything except the Nix store.
- **`@nix`**: the Nix store only. Mounted with `noatime` to reduce metadata writes during package operations.
- **Why separate?** Snapshots of `/` don't capture `/nix/store`, keeping them small. Restoring `/` from a snapshot doesn't touch the store.

## Disko configuration

The flake uses [disko](https://github.com/nix-community/disko) for declarative partitioning. Here's a minimal btrfs layout:

```nix
{ inputs, lib, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk.main = {
      device = lib.mkDefault "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02";
          };
          esp = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
```

See `systems/x86_64-linux/shinji/disk.nix` for a real example.

## Maintenance

### Check filesystem usage

```bash
btrfs filesystem usage /
btrfs filesystem df /
```

### Scrub (data integrity check)

Run occasionally to detect bit rot or disk errors:

```bash
sudo btrfs scrub start /
sudo btrfs scrub status /
```

### Balance

Only needed when adding/removing drives or after heavy usage patterns. Not routine:

```bash
sudo btrfs balance start -dusage=50 /
```

### Compression stats

See how much space compression saves:

```bash
sudo compsize /nix/store
```

## Snapshots

### Manual snapshot before a risky rebuild

```bash
sudo btrfs subvolume snapshot -r / /snapshots/root-$(date -I)
```

### Roll back to a snapshot

```bash
# Boot from a live USB, mount the btrfs volume
sudo mount -o subvol=/ /dev/<disk> /mnt
sudo mv /mnt/@root /mnt/@root-broken
sudo btrfs subvolume snapshot /mnt/snapshots/root-2026-01-01 /mnt/@root
reboot
```

### Delete old snapshots

```bash
sudo btrfs subvolume delete /snapshots/root-2025-12-01
```

## Recovery

### Mount subvolumes from a live USB

```bash
sudo mount /dev/<device> /mnt
# The default subvolume mounts automatically
# Access subvolumes:
ls /mnt/@root
ls /mnt/@nix
```

### Mount a specific subvolume for chroot repair

```bash
sudo mount -o subvol=@root,compress=zstd /dev/<device> /mnt
sudo mount -o subvol=@nix,compress=zstd /dev/<device> /mnt/nix
sudo mount /dev/<esp> /mnt/boot
sudo nixos-enter
```

## Filesystem creation (manual, without disko)

If you need to set up btrfs manually instead of using disko:

```bash
mkfs.btrfs -f /dev/<partition>
mount /dev/<partition> /mnt
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@nix
umount /mnt
mount -o subvol=@root,compress=zstd /dev/<partition> /mnt
mkdir -p /mnt/nix
mount -o subvol=@nix,compress=zstd,noatime /dev/<partition> /mnt/nix
```
