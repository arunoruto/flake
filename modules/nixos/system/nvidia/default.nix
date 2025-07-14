{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.hosts.nvidia.enable = lib.mkEnableOption "Setup Nvidia environment";

  config = lib.mkIf config.hosts.nvidia.enable {
    # Latest kernel does not work well with some web browsers...
    boot.kernelPackages = pkgs.linuxPackages;

    services.xserver.videoDrivers = [ "nvidia" ];

    # boot = {
    #   kernelParams = [ "nvidia.NVreg_EnableGpuFirmware=0" ];
    # };

    environment.systemPackages = with pkgs; [
      nvtopPackages.nvidia
      # egl-wayland
    ];

    hardware = {
      nvidia = {
        open = lib.mkDefault false;
        powerManagement = {
          enable = lib.mkDefault false;
          finegrained = lib.mkDefault false;
        };

        nvidiaSettings = lib.mkDefault false;

        # package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.beta;
        # package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.production;
        package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
        # package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.mkDriver {
        #   version = "555.58.02";
        #   sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
        #   sha256_aarch64 = "sha256-wb20isMrRg8PeQBU96lWJzBMkjfySAUaqt4EgZnhyF8=";
        #   openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
        #   settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
        #   persistencedSha256 = "sha256-a1D7ZZmcKFWfPjjH1REqPM5j/YLWKnbkP9qfRyIyxAw=";
        # };
        # package = lib.mkDefault (
        #   config.boot.kernelPackages.nvidiaPackages.mkDriver {
        #     version = "560.35.03";
        #     sha256_64bit = "sha256-8pMskvrdQ8WyNBvkU/xPc/CtcYXCa7ekP73oGuKfH+M=";
        #     sha256_aarch64 = "sha256-s8ZAVKvRNXpjxRYqM3E5oss5FdqW+tv1qQC2pDjfG+s=";
        #     openSha256 = "sha256-/32Zf0dKrofTmPZ3Ratw4vDM7B+OgpC4p7s+RHUjCrg=";
        #     settingsSha256 = "sha256-kQsvDgnxis9ANFmwIwB7HX5MkIAcpEEAHc8IBOLdXvk=";
        #     persistencedSha256 = "sha256-E2J2wYYyRu7Kc3MMZz/8ZIemcZg68rkzvqEwFAL3fFs=";
        #   }
        # );
      };

      graphics = {
        enable = lib.mkDefault true;
        enable32Bit = true;
        extraPackages =
          with pkgs;
          [
            nvidia-vaapi-driver
          ]
          ++ lib.optionals (!config.services.plex.enable) [
            libva
          ];
      };
    };
  };
}
