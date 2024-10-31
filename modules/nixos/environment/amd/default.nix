{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./rocm.nix
    ./zluda.nix
  ];

  options.amd.enable = lib.mkEnableOption "Setup amd tools";

  config = lib.mkIf config.amd.enable {
    amd = {
      rocm.enable = lib.mkDefault false;
      zluda.enable = lib.mkDefault true;
    };

    services.xserver.videoDrivers = [ "amdgpu" ];

    environment.systemPackages = with pkgs; [
      amdgpu_top
      clinfo
    ];

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
  };
}
