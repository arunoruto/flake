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
    enable = pkgs.stdenv.hostPlatform.isx86_64;
    package = pkgs.unstable.nix-ld;
    libraries = with pkgs; [
      # blas
      stdenv.cc.cc
      glib
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
