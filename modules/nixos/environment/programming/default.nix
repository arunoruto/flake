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

  config = lib.mkIf (lib.elem "development" config.system.tags) {

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
