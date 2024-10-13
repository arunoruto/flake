{lib, ...}: {
  imports = [
    ./laptop.nix
    ./tinypc.nix
    ./workstation.nix
  ];

  laptop.enable = lib.mkDefault false;
  tinypc.enable = lib.mkDefault false;
  workstation.enable = lib.mkDefault false;
}
