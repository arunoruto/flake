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

  config = lib.mkIf (config.lib.tags.hasTag "development") {

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
