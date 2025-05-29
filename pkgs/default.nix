# TODO: create an apple-fonts package inspired by this flake: https://github.com/Lyndeno/apple-fonts.nix
# {
#   pkgs ? import <nixpkgs> {
#     config = {
#       allowUnfree = true;
#     };
#   },
# }:
pkgs:
rec {
  copilot-language-server = pkgs.callPackage ./copilot-language-server { };
  copilot-language-server-fhs = copilot-language-server.fhs;
  # spirv-reflect = pkgs.callPackage ./spirv-reflect { };
  # dpcpp = pkgs.callPackage ./dpcpp { };
  # dpcpp-bin = pkgs.callPackage ./dpcpp/bin.nix { };
  # dpcpp-prop = pkgs.callPackage ./dpcpp/proprietary.nix { };
  # banana-cursor = pkgs.callPackage ./banana-cursor/package.nix {};
  # zluda-rocm5 = pkgs.callPackage ./zluda-rocm5/package.nix { };
  # candy-icons = pkgs.callPackage ./candy-icons/package.nix { };
  mstm = pkgs.callPackage ./mstm { enableMPI = false; };
  teaftp = pkgs.callPackage ./teaftp/package.nix { };
  tftp-now = pkgs.callPackage ./tftp-now/package.nix { };
  unibear = pkgs.callPackage ./unibear/bin.nix { };
  # unibear = pkgs.callPackage ./unibear/package.nix { };
  # wigxjpf = pkgs.callPackage ./wigxjpf/package.nix { };
  # taichi = pkgs.python3Packages.callPackage ./taichi { };
  numba-cuda = pkgs.python3Packages.callPackage ./numba-cuda { };

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

  # kodiPackages = pkgs.kodiPackages.overrideDerivation (prev: import ./kodi.nix pkgs);
  # kodiPackages = pkgs.kodiPackages // (import ./kodi.nix pkgs);
  # kodiPackages = pkgs.kodiPackages;
  # customKodiPackages = import ./kodi.nix pkgs;
}
// (import ./kodi.nix pkgs)
