{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    amd.enable = lib.mkEnableOption "Setup amd tools";
  };

  config = lib.mkIf config.amd.enable {
    # boot.initrd.kernelModules = ["amdgpu"];

    services.xserver.videoDrivers = ["amdgpu"];

    environment.systemPackages =
      (with pkgs; [
        amdgpu_top
        clinfo
      ])
      ++ (with pkgs.rocmPackages; [
        rocminfo
      ]);

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages =
        (with pkgs; [
          amdvlk
        ])
        ++ (with pkgs.rocmPackages; [
          clr.icd
        ]);
    };

    systemd.tmpfiles.rules = let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          clr
          hipcc
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
          # miopen
        ];
      };
    in [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];
    # systemd.tmpfiles.rules = [
    # ];
  };
}
