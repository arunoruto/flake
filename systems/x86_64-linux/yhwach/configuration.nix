{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.primaryUser = "mirza";

  system.tags = [
    "desktop"
    "gaming"
    # "workstation"
  ];

  # RX 9060 XT (RDNA 4)
  hosts.amd.gpu.enable = true;
  boot = {
    # RDNA 4 wants the freshest amdgpu/mesa stack, not the default LTS kernel.
    kernelPackages = pkgs.linuxPackages_latest;

    # Enable systemd-boot selection
    loader.timeout = 10;

    # HDMI 2.1 Fixed Rate Link. The open driver gained FRL in 7.2 but ships it
    # behind DC_FRL_MASK (1 << 10) so that VRR and ALLM could settle first;
    # upstream intends to flip the default in 7.4. 0x2 is the stock mask
    # (DC_MULTI_MON_PP_MCLK_SWITCH), so 0x402 is "stock plus FRL".
    #
    # The parameter is spelled dcfeaturemask, not dc_feature_mask; the kernel
    # silently logs "unknown parameter ... ignored" for the latter and carries
    # on with the default, which reads as the feature simply not working.
    #
    # This is what lets the TV hang off the card's own HDMI port at 4K120
    # instead of going out over DisplayPort through a protocol converter. The
    # converter route works but costs a DSC-compressed link and a PCON whose
    # FRL training fails often enough to black-screen the machine at boot.
    #
    # Gated on the kernel version so it disappears by itself once the default
    # flips; the warning below is the reminder to delete this block outright.
    kernelParams = lib.optional (lib.versionOlder config.boot.kernelPackages.kernel.version "7.4") "amdgpu.dcfeaturemask=0x402";
  };

  warnings = lib.optional (lib.versionAtLeast config.boot.kernelPackages.kernel.version "7.4") ''
    yhwach: kernel ${config.boot.kernelPackages.kernel.version} enables HDMI 2.1
    FRL by default, so the amdgpu.dcfeaturemask=0x402 workaround is no longer
    applied and the block setting it in systems/x86_64-linux/yhwach can go.

    Worth re-testing VRR at the same time: it needs the HDMI Forum VSDB to be
    read for a sink that has no AMD FreeSync block, which is a separate patch
    series ("drm/amd: VRR fixes, HDMI Gaming Features") that had not landed
    when this was written.
  '';

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

    # Two GPUs here, and MangoHud chooses one for itself: the journal shows it
    # probing the 8700K's UHD 630 at 0000:00:02.0 for throttle state. Point it
    # at the card the games actually run on, the same one gamescope is pinned
    # to below.
    mangoapp.pciDev = "0000:03:00.0";
    gamescope = {
      args = [
        "--prefer-vk-device"
        "1002:7590"

        # Nothing about the mode is pinned here on purpose: no --output-width,
        # no --output-height, no --nested-refresh. All three are the arguments
        # to init_drm(), and setting *any* of them takes the first branch of
        # its selection chain, which is what kept the output on 4K120 no matter
        # what Steam's display settings asked for:
        #
        #     if ( preferred_width || preferred_height || preferred_refresh )
        #         mode = find_mode( conn, preferred_width, preferred_height, ... );
        #     if ( !mode && screen type is EXTERNAL )
        #         if ( get_saved_mode( description, mode_info ) )   // <- we want this
        #             mode = find_mode( conn, mode_info.width, ... );
        #     if ( !mode )
        #         mode = find_mode( conn, 0, 0, 0 );                // EDID preferred
        #
        # Leaving them all unset reaches the second branch, which restores
        # whatever was last chosen from GAMESCOPE_MODE_SAVE_FILE (the session
        # script sets that path). So the display settings become the thing
        # that decides the mode, and the choice survives a restart.
        #
        # Two consequences worth knowing. The mode on a fresh profile is the
        # TV's EDID preferred one, 4K60, until something is picked. And with
        # no game open steamcompmgr drives the refresh to rates.back(), the
        # fastest available at the current resolution, so the saved refresh
        # only really holds while a game is running.
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

  # Set system time
  time.hardwareClockInLocalTime = true;
}
