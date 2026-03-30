{
  pkgs,
  lib,
  config,
  ...
}:
let
  hasTag = tag: lib.elem tag config.system.tags;

  isDesktop = hasTag "desktop";
  isLaptop = hasTag "laptop";
  isDevelopment = hasTag "development";

  hasIntelGpu = lib.attrByPath [ "hosts" "intel" "gpu" "enable" ] false config;
  hasAmdGpu = lib.attrByPath [ "hosts" "amd" "gpu" "enable" ] false config;
  hasNvidia = lib.attrByPath [ "hosts" "nvidia" "enable" ] false config;
  hasGpu = hasIntelGpu || hasAmdGpu || hasNvidia;

  corePkgs = with pkgs; [
    file
    git
    killall
    unzip
    vim
    wget
  ];

  opsPkgs = with pkgs; [
    dust
    ffmpeg
    iperf
    nmap
    ntfs3g
    pciutils
    riffdiff
    tlrc
    traceroute
    usbutils
  ];

  desktopPkgs =
    (with pkgs; [
      imagemagickBig
    ])
    ++ (with pkgs.unstable; [
      # ventoy
      zenmap
    ]);

  laptopPkgs = with pkgs; [
    powertop
  ];

  gpuPkgs = with pkgs; [
    clinfo
  ];

  developmentPkgs = with pkgs; [ ];
in
{
  environment.systemPackages =
    corePkgs
    ++ opsPkgs
    ++ lib.optionals isDesktop desktopPkgs
    ++ lib.optionals isLaptop laptopPkgs
    ++ lib.optionals hasGpu gpuPkgs
    ++ lib.optionals isDevelopment developmentPkgs;
}
