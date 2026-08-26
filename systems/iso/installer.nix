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
  # the installer can regenerate it in place.
  facterReport = "/etc/nixos/flake/systems/${pkgs.stdenv.hostPlatform.system}/${hostname}/facter.json";

  # Peek at the target host's config: a lanzaboote host needs its PKI bundle
  # in place before nixos-install runs the bootloader step, or it fails.
  targetConfig = self.nixosConfigurations.${hostname}.config;
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
        ''
          Hardware:   sudo nixos-facter -o ${facterReport}
             (create/refresh the hardware report; a stale one breaks the install)''
      ]
      ++ lib.optionals secureBoot [
        ''
          SB keys:    restore a backed-up ${pkiBundle} to /mnt${pkiBundle},
             or make fresh ones:  sudo create-sb-keys
             (fresh keys boot only after firmware re-enrollment!)''
      ]
      ++ [
        "Install:    sudo nixos-install --flake /etc/nixos/flake#${hostname} --root /mnt"
        "Reboot:     sudo reboot"
      ];
    in
    ''
      === ${hostname} Installer ===
      ${lib.concatStringsSep "\n" (lib.imap1 (i: step: "${toString i}. ${step}") steps)}

      Resuming after a reboot? Step 1 REFORMATS — remount instead:
        sudo disko --mode mount --flake /etc/nixos/flake#${hostname}

      Autoinstall:  reboot and add 'autoinstall' to kernel cmdline
      ===================
    '';

  systemd.services.autoinstall = {
    description = "Autoinstall NixOS ${hostname} from embedded flake";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig.Type = "oneshot";
    path = [
      disko-pkg
      pkgs.nixos-facter
      pkgs.nixos-install-tools
      pkgs.coreutils
      pkgs.util-linux
    ];
    script = ''
      if grep -q 'autoinstall' /proc/cmdline; then
        echo "==> Autoinstall triggered: partitioning disk..."
        disko --mode disko --flake /etc/nixos/flake#${hostname}
        # Refresh (never introduce) the hardware report: a stale one loads
        # drivers for hardware that is gone, which fails the initrd build.
        if [ -e ${facterReport} ]; then
          echo "==> Refreshing hardware report..."
          nixos-facter -o ${facterReport}
        fi
        ${lib.optionalString secureBoot ''
          echo "==> Setting up secure boot keys..."
          ${create-sb-keys}/bin/create-sb-keys
        ''}echo "==> Installing NixOS..."
        nixos-install --flake /etc/nixos/flake#${hostname} --root /mnt --no-root-passwd
        echo "==> Done! Rebooting in 5s..."
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
