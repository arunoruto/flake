# TODO: create an apple-fonts package inspired by this flake: https://github.com/Lyndeno/apple-fonts.nix
pkgs: {
  # banana-cursor = pkgs.callPackage ./banana-cursor/package.nix {};
  zluda-rocm5 = pkgs.callPackage ./zluda-rocm5/package.nix { };
  candy-icons = pkgs.callPackage ./candy-icons/package.nix { };
  mstm = pkgs.callPackage ./mstm/parallel.nix { };
  zen-browser = pkgs.callPackage ./zen-browser/package.nix { };
}
