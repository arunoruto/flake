{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./python.nix
  ];

  config = lib.mkIf (lib.hasTag config "development") {

    environment = {
      systemPackages = with pkgs; [
        gfortran
        gcc
        gcc-unwrapped
        gnumake
        # julia-bin
        #unstable.ruff
        #ruff

        # rust
        cargo
        rustc

        # misc
        hyperfine
      ];
    };
  };
}
