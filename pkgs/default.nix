pkgs: {
  # banana-cursor = pkgs.callPackage ./banana-cursor/package.nix {};
  zluda-rocm5 = pkgs.callPackage ./zluda-rocm5/package.nix {};
  candy-icons = pkgs.callPackage ./candy-icons/package.nix {};
  mstm = pkgs.callPackage ./mstm/parallel.nix {};
}
