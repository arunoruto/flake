{
  pkgs,
  config,
  lib,
  ...
}: {
  options.amd.zluda.enable = lib.mkEnableOption "ZLUDA: alternative for CUDA but for AMD";

  config = lib.mkIf config.amd.zluda.enable {
    environment.systemPackages = with pkgs; [
      zluda
    ];

    # systemd.tmpfiles.rules = let
    #   rocmEnv = pkgs.symlinkJoin {
    #     name = "rocm-combined";
    #     paths = with pkgs.rocmPackages_5; [
    #       clr
    #       llvm.lld
    #       hipcc
    #       hipfft
    #       hipsolver
    #       hipblas
    #       rocblas
    #       rocalution
    #       rocfft
    #       rocm-runtime
    #       rocrand
    #       rocsparse
    #       rocsolver
    #       rccl
    #       miopen
    #     ];
    #   };
    # in [
    #   "L+    /opt/rocm       -    -    -     -    ${rocmEnv}"
    #   "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    # ];
  };
}
