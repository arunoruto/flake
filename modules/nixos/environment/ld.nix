{
  inputs,
  pkgs,
  ...
}: {
  # imports = [
  #   inputs.nix-ld.nixosModules.nix-ld
  # ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
    ];
  };
}
