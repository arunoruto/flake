# TODO: create an apple-fonts package inspired by this flake: https://github.com/Lyndeno/apple-fonts.nix
# {
#   pkgs ? import <nixpkgs> {
#     config = {
#       allowUnfree = true;
#     };
#   },
# }:
pkgs: rec {
  # dpcpp = pkgs.callPackage ./dpcpp { };
  # banana-cursor = pkgs.callPackage ./banana-cursor/package.nix {};
  zluda-rocm5 = pkgs.callPackage ./zluda-rocm5/package.nix { };
  # candy-icons = pkgs.callPackage ./candy-icons/package.nix { };
  mstm = pkgs.callPackage ./mstm/parallel.nix { };
  # wigxjpf = pkgs.callPackage ./wigxjpf/package.nix { };

  # Work testing
  # isis = pkgs.callPackage ./isis/package.nix {
  #   inherit inja;
  #   inherit ale;
  #   inherit cspice;
  #   inherit csm;
  # };
  # inja = pkgs.callPackage ./isis/inja.nix { };
  # ale = pkgs.callPackage ./ale/package.nix { };
  # cspice = pkgs.callPackage ./cspice/package.nix { };
  # csm = pkgs.callPackage ./csm/package.nix { };

  # python3 = pkgs.python3.override {
  #   packageOverrides = final: prev: import ./python.nix pkgs;
  # };
}
