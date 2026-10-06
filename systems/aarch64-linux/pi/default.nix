{
  config,
  inputs,
  pkgs,
  ...
}:
let
  inherit (config.boot.kernelPackages) kernel;
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.steamix.nixosModules.default

    ./configuration.nix
    ./hardware-configuration.nix
  ];

  # Vendor kernel from nixos-raspberrypi instead of nixos-hardware's: theirs is
  # built against their own nixpkgs pin and served from their cache, so the
  # 2 GB Pi never has to compile a kernel itself.
  boot.kernelPackages = inputs.nixos-raspberrypi.legacyPackages.aarch64-linux.linuxPackages_rpi4;

  # Device-tree overlays are compiled against
  # ${kernel.dev}/lib/modules/<ver>/source/scripts/dtc/include-prefixes, but
  # the cache only carries the kernel's out/modules outputs, so `dev` would
  # rebuild the whole kernel. Those include paths are just symlinks into the
  # source tree, so hand the overlay builder a `dev` that is the source.
  hardware.deviceTree.kernelPackage = kernel // {
    dev = pkgs.runCommand "${kernel.name}-dtc-includes" { } ''
      mkdir -p $out/lib/modules/${kernel.modDirVersion}
      ln -s ${kernel.src} $out/lib/modules/${kernel.modDirVersion}/source
    '';
  };
  nix.settings = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
}
