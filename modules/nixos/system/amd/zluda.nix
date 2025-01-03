{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.hosts.amd.zluda.enable = lib.mkEnableOption "ZLUDA: alternative for CUDA but for AMD";

  config = lib.mkIf config.hosts.amd.zluda.enable {
    environment.systemPackages = with pkgs; [
      zluda-rocm5
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
