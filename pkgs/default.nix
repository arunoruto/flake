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
  beszel = pkgs.callPackage ./beszel/package.nix { };
  adda = pkgs.callPackage ./adda/package.nix { };
  adda-mpi = pkgs.callPackage ./adda/package.nix { target = "mpi"; };
  adda-ocl = pkgs.callPackage ./adda/package.nix { target = "ocl"; };
  adda-gui = pkgs.callPackage ./adda-gui/package.nix { inherit adda; };
  adda-gui-update-script = adda-gui.mitmCache.updateScript;
  copilot-language-server = pkgs.callPackage ./copilot-language-server/package.nix { };
  # spirv-reflect = pkgs.callPackage ./spirv-reflect { };
  # dpcpp = pkgs.callPackage ./dpcpp { };
  # dpcpp-bin = pkgs.callPackage ./dpcpp/bin.nix { };
  dpcpp-prop = pkgs.callPackage ./dpcpp/proprietary4.nix { };
  gemini-cli-custom = pkgs.callPackage ./gemini-cli/package.nix { };
  # fileflows = pkgs.callPackage ./fileflows/package.nix { };
  # banana-cursor = pkgs.callPackage ./banana-cursor/package.nix {};
  # zluda-rocm5 = pkgs.callPackage ./zluda-rocm5/package.nix { };
  # candy-icons = pkgs.callPackage ./candy-icons/package.nix { };
  mstm = pkgs.callPackage ./mstm { enableMPI = false; };
  # tdarr = pkgs.callPackage ./tdarr/package.nix { };
  # tdarr-node = pkgs.callPackage ./tdarr/node.nix { };
  # tdarr-server = pkgs.callPackage ./tdarr/server.nix { };
  teaftp = pkgs.callPackage ./teaftp/package.nix { };
  terminus = pkgs.callPackage ./terminus/package.nix { };
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
