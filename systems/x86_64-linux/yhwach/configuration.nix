{ pkgs, ... }:
{
  users.primaryUser = "mirza";

  system.tags = [
    "desktop"
    "gaming"
    # "workstation"
  ];

  # RX 9060 XT (RDNA 4)
  hosts.amd.gpu.enable = true;
  # RDNA 4 wants the freshest amdgpu/mesa stack, not the default LTS kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Steam machine: boot straight into Gaming Mode, with GNOME one
  # "Switch to Desktop" away (see modules/steamos and docs/steamos/).
  steamos = {
    enable = true;
    desktopSession = "gnome";
  };
  # 26.05's gamescope 3.16.23 mis-composites after the Big Picture overlay
  # closes (black region where the menu was, game never refocused); trying
  # the newer compositor from unstable (3.16.25).
  programs.gamescope.package = pkgs.unstable.gamescope;

  # NOTE: currently inert — yubikey.enable came from the workstation tag,
  # which is off; set yubikey.enable = true if this box should keep it.
  yubikey.signing = "giyu";
  # netbird.enable = true;

  # Lanzaboote secure boot: deferred until the PKI bundle is in place.
  # Re-enable once /etc/secureboot holds keys, then enroll in firmware
  # (sbctl enroll-keys -m) — see docs/iso.md.
  # secureboot.enable = true;

  # Enable systemd-boot selection
  boot.loader.timeout = 10;

  # Set system time
  time.hardwareClockInLocalTime = true;
}
