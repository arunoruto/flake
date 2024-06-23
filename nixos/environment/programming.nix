{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      gfortran
      gcc
      gcc-unwrapped
      gnumake
      julia-bin
      python3
      #unstable.ruff
      #ruff

      # rust
      cargo
      rustc

      # misc
      hyperfine
    ];
  };
}
