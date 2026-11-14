# One generic installer for `just install <host> <addr>`. It carries no flake
# and no host closure: nixos-anywhere builds locally and copies the system
# over SSH. The installer profile sets VARIANT_ID=installer, which makes
# nixos-anywhere skip its kexec step and install from this live system.
{
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ./checksums.nix
  ];

  boot.zfs.forceImportRoot = false;
  isoImage.edition = "anywhere";
  networking.hostName = "installer";

  # The same keys modules/nixos/services/ssh.nix gives root on every host.
  users.users.root.openssh.authorizedKeys.keyFiles =
    lib.concatMap
      (user: lib.filesystem.listFilesRecursive (lib.path.append ../../. "homes/${user}/keys"))
      [
        "mar"
        "mirza"
      ];

  # Reachable as root@installer.local, no hunting for the DHCP address.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # For --generate-hardware-config; saves fetching it on the target.
  environment.systemPackages = [ pkgs.nixos-facter ];
}
