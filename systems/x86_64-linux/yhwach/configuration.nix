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

  # HDMI 2.1 Fixed Rate Link. The open driver gained FRL in 7.2 but ships it
  # behind DC_FRL_MASK (1 << 10) so that VRR and ALLM could settle first;
  # upstream plans to flip the default in 7.4. 0x2 is the stock mask
  # (DC_MULTI_MON_PP_MCLK_SWITCH), so 0x402 is "stock plus FRL".
  #
  # The parameter is spelled dcfeaturemask, not dc_feature_mask; the kernel
  # silently logs "unknown parameter ... ignored" for the latter.
  #
  # This is what lets the TV hang off the card's own HDMI port at 4K120
  # instead of going out over DisplayPort through a protocol converter. The
  # converter route works but costs a DSC-compressed link and a PCON whose
  # FRL training fails often enough to black-screen the machine at boot.
  boot.kernelParams = [ "amdgpu.dcfeaturemask=0x402" ];

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

        # 4K120 has to be asked for; the TV's preferred EDID mode is 4K60.
        #
        # Measured on the native HDMI link rather than assumed: 3840x2160@120
        # at a 1188 MHz pixel clock, RGB 12-bit BT2020, uncompressed, carried
        # by HDMI 2.1 FRL (see boot.kernelParams above). No DSC, and no
        # protocol converter in the path.
        #
        # Careful with --nested-refresh: it is the *game* refresh rate, not the
        # output mode. Setting it to 60 leaves the CRTC at 120. gamescope has
        # no flag or convar for output refresh on the DRM backend, so the mode
        # cannot be pinned from here at all.
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
