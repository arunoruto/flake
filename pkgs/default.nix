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
  # zen-browser = pkgs.callPackage ./zen-browser/package.nix { };
  wigxjpf = pkgs.callPackage ./wigxjpf/package.nix { };
  pywigxjpf = pkgs.python3Packages.callPackage ./wigxjpf/pypackage.nix { };

  # Work testing
  isis = pkgs.callPackage ./isis/package.nix {
    inherit inja;
    inherit ale;
    inherit cspice;
    inherit csm;
  };
  inja = pkgs.callPackage ./isis/inja.nix { };
  ale = pkgs.callPackage ./ale/package.nix { };
  cspice = pkgs.callPackage ./cspice/package.nix { };
  csm = pkgs.callPackage ./csm/package.nix { };
}
