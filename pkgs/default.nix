# TODO: create an apple-fonts package inspired by this flake: https://github.com/Lyndeno/apple-fonts.nix
# {
#   pkgs ? import <nixpkgs> {
#     config = {
#       allowUnfree = true;
#     };
#   },
# }:
pkgs: rec {
  # banana-cursor = pkgs.callPackage ./banana-cursor/package.nix {};
  zluda-rocm5 = pkgs.callPackage ./zluda-rocm5/package.nix { };
  candy-icons = pkgs.callPackage ./candy-icons/package.nix { };
  mstm = pkgs.callPackage ./mstm/parallel.nix { };
  zen-browser = pkgs.callPackage ./zen-browser/package.nix { };
  isis = pkgs.callPackage ./isis/package.nix {
    # embree = embree3;
    # tnt = tnt126;
    # jama = jama125;
    # nanoflann = nanoflann132;
    inherit inja;
    inherit ale;
    inherit cspice;
    inherit csm;
  };
  # embree3 = pkgs.callPackage ./isis/embree3.nix { };
  inja = pkgs.callPackage ./isis/inja.nix { };
  ale = pkgs.callPackage ./ale/package.nix { };
  cspice = pkgs.callPackage ./cspice/package.nix { };
  csm = pkgs.callPackage ./csm/package.nix { };
}
