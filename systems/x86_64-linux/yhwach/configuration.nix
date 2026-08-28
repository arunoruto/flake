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
  # The overlay-close symptom this was chasing (game stops being drawn and
  # stops taking input until Steam is forced to re-assert focus) turned out to
  # be the session, not the compositor: Gaming Mode needs a second Xwayland
  # server for games. modules/steamos now sets that up, so this pin is likely
  # unnecessary — drop it back to the release gamescope and retest.
  programs.gamescope.package = pkgs.unstable.gamescope;
  # The WSI Vulkan layer talks a versioned protocol to gamescope; keep it on
  # the same build as the compositor above.
  steamos.gamescope.wsi = {
    packages = [ pkgs.unstable.gamescope-wsi ];
    packages32 = [ pkgs.unstable.pkgsi686Linux.gamescope-wsi ];
  };

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
