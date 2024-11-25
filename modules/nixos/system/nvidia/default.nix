{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.hosts.nvidia.enable = lib.mkEnableOption "Setup Nvidia environment";

  config = lib.mkIf config.hosts.nvidia.enable {
    boot = {
      kernelPackages = pkgs.linuxPackages;
      # kernelParams = [ "nvidia.NVreg_EnableGpuFirmware=0" ];
    };

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];

    environment.systemPackages = with pkgs; [
      egl-wayland
    ];

    hardware = {
      nvidia = {
        # Modesetting is required.
        modesetting.enable = lib.mkDefault true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        # Enable this if you have graphical corruption issues or application crashes after waking
        # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
        # of just the bare essentials.
        powerManagement.enable = lib.mkDefault false;

        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = lib.mkDefault false;

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from driver 515.43.04+
        # Currently alpha-quality/buggy, so false is currently the recommended setting.
        open = lib.mkDefault false;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = lib.mkDefault false;

        # package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.beta;
        # package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.production;
        # package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
        # package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.mkDriver {
        #   version = "555.58.02";
        #   sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
        #   sha256_aarch64 = "sha256-wb20isMrRg8PeQBU96lWJzBMkjfySAUaqt4EgZnhyF8=";
        #   openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
        #   settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
        #   persistencedSha256 = "sha256-a1D7ZZmcKFWfPjjH1REqPM5j/YLWKnbkP9qfRyIyxAw=";
        # };
        package = lib.mkDefault (
          config.boot.kernelPackages.nvidiaPackages.mkDriver {
            version = "560.35.03";
            sha256_64bit = "sha256-8pMskvrdQ8WyNBvkU/xPc/CtcYXCa7ekP73oGuKfH+M=";
            sha256_aarch64 = "sha256-s8ZAVKvRNXpjxRYqM3E5oss5FdqW+tv1qQC2pDjfG+s=";
            openSha256 = "sha256-/32Zf0dKrofTmPZ3Ratw4vDM7B+OgpC4p7s+RHUjCrg=";
            settingsSha256 = "sha256-kQsvDgnxis9ANFmwIwB7HX5MkIAcpEEAHc8IBOLdXvk=";
            persistencedSha256 = "sha256-E2J2wYYyRu7Kc3MMZz/8ZIemcZg68rkzvqEwFAL3fFs=";
          }
        );
      };
      graphics = {
        enable = lib.mkDefault true;
      };
    };
  };
}
