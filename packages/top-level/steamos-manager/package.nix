# SteamOS Manager: the system daemon Steam talks to for OS-level features.
#
# Built unpatched, unlike Jovian's derivation. Theirs carries a patch rewiring
# the daemon to Steam Deck firmware tools (BIOS and dock updaters, Jupiter
# hardware support), which drags in four Deck-only packages to serve hardware a
# desktop does not have. Upstream's own design makes that unnecessary: the
# daemon probes at startup and only publishes the interfaces it can actually
# back, and Steam "will check which features are available at startup and
# restrict the settings it presents to the user based on feature availability".
# So on a desktop the firmware interfaces simply never appear, which is correct.
{
  lib,
  rustPlatform,
  fetchzip,
  pkg-config,
  glib,
  gsettings-desktop-schemas,
  speechd-minimal,
  udev,
  wrapGAppsNoGuiHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "steamos-manager";
  version = "26.4.1";

  src = fetchzip {
    url = "https://gitlab.steamos.cloud/holo/steamos-manager/-/archive/v${finalAttrs.version}/steamos-manager-v${finalAttrs.version}.tar.gz";
    hash = "sha256-NVbYXZOd7+cUf0wDqptoHUBzHN/ukctcltir2axvAJo=";
  };

  cargoHash = "sha256-UT1rmETSkBpSANo1Q36FCFJ2GoSedZhMmxqCOUe6AwE=";

  __structuredAttrs = true;
  strictDeps = true;

  # The tests assume Steam Deck hardware and FHS paths.
  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    glib
    rustPlatform.bindgenHook
    wrapGAppsNoGuiHook
  ];

  buildInputs = [
    glib
    gsettings-desktop-schemas
    speechd-minimal
    udev
  ];

  # Upstream installs to /usr and its units say so. Point them at the store
  # instead of patching the source.
  postPatch = ''
    substituteInPlace data/system/*.service data/user/steamos-manager*.service \
      --replace-warn /usr/lib/steamos-manager "$out/lib/steamos-manager" \
      --replace-warn /usr/bin/steamosctl "$out/bin/steamosctl"

    # Upstream probes /usr/lib/sddm/sddm.conf.d for a marker file to decide
    # whether it manages sessions, and only publishes SessionManagement1 if it
    # finds one. Nothing lives under /usr here, so the interface never appeared
    # and "Switch to Desktop" had nothing to call. Jovian patches this same
    # constant; a substitution does the job without carrying a patch file.
    substituteInPlace steamos-manager/src/session.rs \
      --replace-fail '/usr/lib/sddm/sddm.conf.d' '/etc/sddm.conf.d'
  '';

  # Mirrors upstream's Makefile install target, minus the pieces that only make
  # sense on SteamOS: the SDDM drop-in, and orca.service (the screen reader is
  # the consumer's business, and this module tree does not manage one).
  postInstall = ''
    install -d -m0755 "$out/lib" "$out/share/steamos-manager/remotes.d"

    mv "$out/bin/steamos-manager" "$out/lib/steamos-manager"

    install -D -m644 -t "$out/share/steamos-manager/devices" data/devices/*
    install -D -m644 -t "$out/share/dbus-1/interfaces" data/interfaces/*
    install -D -m644 data/platform.toml -t "$out/share/steamos-manager"

    install -D -m644 data/system/com.steampowered.SteamOSManager1.service \
      -t "$out/share/dbus-1/system-services"
    install -D -m644 data/system/com.steampowered.SteamOSManager1.conf \
      -t "$out/share/dbus-1/system.d"
    install -D -m644 data/system/steamos-manager.service -t "$out/lib/systemd/system"

    install -D -m644 data/user/com.steampowered.SteamOSManager1.service \
      -t "$out/share/dbus-1/services"
    install -D -m644 \
      data/user/steamos-manager.service \
      data/user/steamos-manager-session-cleanup.service \
      data/user/steamos-manager-configure-cecd.service \
      -t "$out/lib/systemd/user"
  '';

  postFixup = ''
    wrapGApp "$out/lib/steamos-manager"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "System daemon abstracting Steam's interactions with the OS";
    homepage = "https://gitlab.steamos.cloud/holo/steamos-manager";
    license = lib.licenses.bsd2;
    mainProgram = "steamosctl";
    platforms = lib.platforms.linux;
  };
})
