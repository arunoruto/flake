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

    # The SteamOS-shaped login path rather than the self-contained greetd
    # loop: SDDM autologin, with session switching handled by SteamOS
    # Manager the way Valve's image does it. Worth the extra moving parts
    # here because "Switch to Desktop" is then Steam talking to the daemon
    # over D-Bus, instead of our own script guessing at the running session.
    loginManager = "sddm";

    # The plugin loader is packaged in this repo (packages/top-level), so
    # pkgs.decky-loader resolves here even though nixpkgs has no such package.
    decky-loader = {
      enable = true;
      plugins = with pkgs.deckyPlugins; [
        hltb-for-deck
        protondb-decky
      ];
    };

    # This box has two GPUs — the RX 9060 XT and the 8700K's UHD 630 — and
    # nothing pins which one gamescope composites on. Left to itself it picks
    # a Vulkan device and then opens the DRM node that matches it, so which
    # card it lands on rides on kernel enumeration order, which is not stable
    # across boots (amdgpu has come up as both card0 and card1 here). When it
    # chose the iGPU it opened i915's node, which has no connected output,
    # failed to create a backend, and greetd hit its restart limit with a
    # black screen. Pin the discrete card by PCI ID.
    gamescope = {
      args = [
        "--prefer-vk-device"
        "1002:7590"

        # The TV's *preferred* EDID mode is 4K60, so gamescope settles there
        # even though the driver also offers 3840x2160@120 (and @100). Ask for
        # it explicitly. 4K120 is a 1188 MHz pixel clock, over twice what
        # HDMI 2.0's 600 MHz TMDS ceiling carries, so amdgpu drives it as
        # YCbCr 4:2:0 (594 MHz) — which this TV advertises for exactly these
        # modes. Chroma subsampling costs nothing in games or video and softens
        # small text a little. An unavailable mode falls back to the preferred
        # one rather than failing, so this cannot black-screen the box.
        "--output-width"
        "3840"
        "--output-height"
        "2160"
        "--nested-refresh"
        "120"
      ];

      # gamescope only builds a dynamic refresh-rate list for *internal*
      # panels; for external displays the switching Steam's display settings
      # would drive is off behind this ConVar. Any ConVar can be overridden
      # with a `gamescope_<name>` environment variable.
      env.gamescope_drm_allow_dynamic_modes_for_external_display = "true";
    };
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
    package = pkgs.unstable.gamescope-wsi;
    package32 = pkgs.unstable.pkgsi686Linux.gamescope-wsi;
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
