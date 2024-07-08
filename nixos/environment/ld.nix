{pkgs, ...}: {
  programs.nix-ld.dev = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
    ];
  };
}
