{
  # inputs,
  pkgs,
  ...
}: {
  # imports = [
  #   inputs.nix-ld.nixosModules.nix-ld
  # ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.unstable.nix-ld;
    libraries = with pkgs; [
      stdenv.cc.cc
      glibc
      zlib
    ];
  };
}
