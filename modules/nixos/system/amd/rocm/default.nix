{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.hosts.amd.rocm.enable = lib.mkEnableOption "Setup ROCm packages";

  config = lib.mkIf config.hosts.amd.rocm.enable {
    environment.systemPackages = with pkgs.rocmPackages; [
      rocminfo
    ];

    systemd.tmpfiles.rules =
      let
        rocmEnv = pkgs.symlinkJoin {
          name = "rocm-combined";
          paths = with pkgs.rocmPackages_5; [
            clr
            llvm.lld
            hipcc
            hipfft
            hipsolver
            hipblas
            rocblas
            rocalution
            rocfft
            rocm-runtime
            rocrand
            rocsparse
            rocsolver
            rccl
            miopen
          ];
        };
      in
      [
        "L+    /opt/rocm       -    -    -     -    ${rocmEnv}"
        "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
      ];
  };
}
