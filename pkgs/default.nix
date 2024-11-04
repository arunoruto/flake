# TODO: create an apple-fonts package inspired by this flake: https://github.com/Lyndeno/apple-fonts.nix
pkgs: rec {
  # banana-cursor = pkgs.callPackage ./banana-cursor/package.nix {};
  zluda-rocm5 = pkgs.callPackage ./zluda-rocm5/package.nix { };
  candy-icons = pkgs.callPackage ./candy-icons/package.nix { };
  mstm = pkgs.callPackage ./mstm/parallel.nix { };
  zen-browser = pkgs.callPackage ./zen-browser/package.nix { };
  # isis = pkgs.callPackage ./isis/package.nix {
  #   embree = embree3;
  #   inja = inja;
  #   ale = ale;
  # };
  ale = pkgs.callPackage ./ale/package.nix { };
  embree3 = pkgs.callPackage ./isis/embree3.nix { };
  inja = pkgs.callPackage ./isis/inja.nix { };
}
