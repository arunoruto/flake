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

  options.programming.enable = lib.mkEnableOption "Setup programming tools";

  config = lib.mkIf config.programming.enable {
    python.enable = lib.mkDefault true;

    environment = {
      systemPackages = with pkgs; [
        gfortran
        gcc
        gcc-unwrapped
        gnumake
        julia-bin
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
