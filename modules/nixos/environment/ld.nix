{
  # inputs,
  pkgs,
  ...
}:
{
  # imports = [
  #   inputs.nix-ld.nixosModules.nix-ld
  # ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.unstable.nix-ld;
    libraries = with pkgs; [
      # blas
      stdenv.cc.cc
      glibc
      # libGL
      opensc
      zlib
    ];
  };

  environment.sessionVariables = {
    NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
  };
}
