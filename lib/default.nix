lib: {
  systemConfig = import ../systems/lib.nix lib;
  arr = import ../modules/nixos/media/arr/lib.nix lib;
}
