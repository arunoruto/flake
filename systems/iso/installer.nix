{
  config,
  lib,
  pkgs,
  modulesPath,
  self,
  inputs,
  hostname,
  ...
}:
let
  disko-pkg = inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko;

  # Where the embedded flake keeps this host's hardware report. A stale report
  # is actively harmful (it force-loads drivers for hardware that is gone), so
  # the installer regenerates it in place at boot (see facter-report below).
  facterReport = "/etc/nixos/flake/systems/${pkgs.stdenv.hostPlatform.system}/${hostname}/facter.json";
  # Where the fresh report is left on the installed system, since the live
  # copy of the flake is gone after the reboot. Pull it back into the repo from
  # there.
  savedReport = "/etc/nixos/facter.json";

  # Peek at the target host's config: a lanzaboote host needs its PKI bundle
  # in place before nixos-install runs the bootloader step, or it fails.
  targetConfig = self.nixosConfigurations.${hostname}.config;
  # Hosts without a facter.json keep their hand-written hardware config; the
  # installer never introduces a report on them.
  hasReport = targetConfig.hardware.facter.reportPath != null;
  secureBoot = targetConfig.boot.lanzaboote.enable or false;
  pkiBundle = lib.optionalString secureBoot (toString targetConfig.boot.lanzaboote.pkiBundle);

  # Fresh keys make the install succeed, but the firmware only accepts them
  # after (re-)enrollment — restoring the previous machine's bundle instead
  # keeps the already-enrolled keys working.
  create-sb-keys = pkgs.writeShellScriptBin "create-sb-keys" ''
    set -eu
    if [ -e /mnt${pkiBundle}/keys/db/db.key ]; then
      echo "Secure boot keys already present at /mnt${pkiBundle}, leaving them alone."
      exit 0
    fi
    echo "Creating fresh secure boot keys at /mnt${pkiBundle}..."
    echo "(Re-enroll after first boot: firmware into setup mode, then 'sbctl enroll-keys'.)"
    ${pkgs.sbctl}/bin/sbctl create-keys
    mkdir -p /mnt${pkiBundle}
    src=/var/lib/sbctl
    [ -e "$src/keys/db/db.key" ] || src=/etc/secureboot
    cp -a "$src/." /mnt${pkiBundle}/
  '';
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  boot.zfs.forceImportRoot = false;

  nix.settings = {
    experimental-features = "flakes nix-command";
    accept-flake-config = true;
  };

  isoImage = {
    edition = hostname;
    contents = [
      {
        source = self;
        target = "/nixos-flake";
      }
    ];
    storeContents = [
      config.system.build.toplevel
      disko-pkg
    ];
  };

  environment.systemPackages = [
    disko-pkg
    pkgs.git
    pkgs.helix
    pkgs.nixos-facter
  ]
  ++ lib.optionals secureBoot [
    pkgs.sbctl
    create-sb-keys
  ];

  boot.postBootCommands = lib.mkAfter ''
    if [ ! -e /etc/nixos/flake ]; then
      cp -r /iso/nixos-flake /etc/nixos/flake
      chmod -R u+w /etc/nixos/flake
    fi
  '';

  users.motd =
    let
      steps = [
        "Partition:  sudo disko --mode disko --flake /etc/nixos/flake#${hostname}"
      ]
      ++ lib.optionals secureBoot [
        ''
          SB keys:    restore a backed-up ${pkiBundle} to /mnt${pkiBundle},
             or make fresh ones:  sudo create-sb-keys
             (fresh keys boot only after firmware re-enrollment!)''
      ]
      ++ [
        "Install:    sudo nixos-install --flake /etc/nixos/flake#${hostname} --root /mnt"
      ]
      ++ lib.optionals hasReport [
        ''
          Save:       sudo install -Dm644 ${facterReport} /mnt${savedReport}
             (then commit it: scp ${hostname}:${savedReport} systems/${pkgs.stdenv.hostPlatform.system}/${hostname}/)''
      ]
      ++ [ "Reboot:     sudo reboot" ];
    in
    ''
      === ${hostname} Installer ===
      ${lib.optionalString hasReport "Hardware report regenerated at boot: systemctl status facter-report"}
      ${lib.concatStringsSep "\n" (lib.imap1 (i: step: "${toString i}. ${step}") steps)}

      Resuming after a reboot? Step 1 REFORMATS — remount instead:
        sudo disko --mode mount --flake /etc/nixos/flake#${hostname}

      Autoinstall:  reboot and add 'autoinstall' to kernel cmdline
      ===================
    '';

  # Refresh (never introduce) the hardware report as soon as the ISO is up, so
  # neither install path can run against the report of another machine. Only
  # the live copy of the flake is touched; the ISO itself stays as built.
  systemd.services.facter-report = lib.mkIf hasReport {
    description = "Regenerate the ${hostname} hardware report on this machine";
    wantedBy = [ "multi-user.target" ];
    # Probe only after udev has seen every device.
    wants = [ "systemd-udev-settle.service" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.nixos-facter ];
    script = ''
      nixos-facter -o ${facterReport}
      echo "Hardware report written to ${facterReport}"
    '';
  };

  systemd.services.autoinstall = {
    description = "Autoinstall NixOS ${hostname} from embedded flake";
    wantedBy = [ "multi-user.target" ];
    # Requires, not Wants: better no install than one against a stale report.
    requires = lib.optional hasReport "facter-report.service";
    after = [ "network.target" ] ++ lib.optional hasReport "facter-report.service";
    serviceConfig.Type = "oneshot";
    path = [
      disko-pkg
      pkgs.nixos-install-tools
      pkgs.coreutils
      pkgs.util-linux
    ];
    script = ''
      if grep -q 'autoinstall' /proc/cmdline; then
        echo "==> Autoinstall triggered: partitioning disk..."
        disko --mode disko --flake /etc/nixos/flake#${hostname}
        ${lib.optionalString secureBoot ''
          echo "==> Setting up secure boot keys..."
          ${create-sb-keys}/bin/create-sb-keys
        ''}echo "==> Installing NixOS..."
        nixos-install --flake /etc/nixos/flake#${hostname} --root /mnt --no-root-passwd
        ${lib.optionalString hasReport ''
          echo "==> Saving hardware report to ${savedReport}..."
          install -Dm644 ${facterReport} /mnt${savedReport}
        ''}echo "==> Done! Rebooting in 5s..."
        sleep 5
        reboot -f
      fi
    '';
  };

  system.build.isoChecksums = pkgs.runCommand "iso-${hostname}-checksums" { } ''
    mkdir -p $out/iso
    cp ${config.system.build.isoImage}/iso/*.iso $out/iso/
    cd $out/iso
    for iso in *.iso; do
      sha256sum "$iso" > "$iso.sha256"
    done
    cd $out
    sha256sum iso/*.iso > SHA256SUMS
  '';
}
