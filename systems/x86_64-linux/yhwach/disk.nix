# Disk layout for the fresh install: UEFI-only, btrfs with the /nix store on
# its own subvolume (same scheme as kenpachi).
#
# The target is the ~500G Samsung NVMe that came with the 2026-08 upgrade,
# pinned by its EUI so disko can never grab another drive — the machine holds
# several, and bare /dev/nvmeXn1 names shuffle between boots. Verify from the
# installer with `lsblk -o NAME,SIZE,MODEL,SERIAL`; a different target can be
# forced via
#   disko --mode disko --arg device '"/dev/disk/by-id/..."' ./disk.nix
{ inputs, lib, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk.main = {
      device = lib.mkDefault "/dev/disk/by-id/nvme-eui.344754304e3233900025384600000001";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            name = "EFI system partition";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          # No swap: 32G of RAM is plenty for a gaming box. If memory pressure
          # ever becomes real, prefer `zramSwap.enable` over reformatting.
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
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
