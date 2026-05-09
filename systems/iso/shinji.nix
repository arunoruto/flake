{
  config,
  lib,
  pkgs,
  modulesPath,
  self,
  inputs,
  ...
}:
let
  disko-pkg = inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko;
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  isoImage.contents = [
    {
      source = self;
      target = "/nixos-flake";
    }
  ];

  isoImage.storeContents = [
    config.system.build.toplevel
    disko-pkg
  ];

  environment.systemPackages = [
    disko-pkg
    pkgs.git
    pkgs.helix
  ];

  boot.postBootCommands = lib.mkAfter ''
        if [ ! -e /etc/nixos/flake ]; then
          cp -r /iso/nixos-flake /etc/nixos/flake
          chmod -R u+w /etc/nixos/flake
        fi
        if ! grep -q 'autoinstall' /proc/cmdline; then
          cat << 'HEREDOC' >> /etc/motd

    === Shinji Installer ===
    1. Partition:  sudo disko --mode disko /etc/nixos/flake#shinji
    2. Install:    sudo nixos-install --flake /etc/nixos/flake#shinji --root /mnt
    3. Reboot:     sudo reboot

    Autoinstall:  reboot and add 'autoinstall' to kernel cmdline
    ===================
    HEREDOC
        fi
  '';

  systemd.services.autoinstall = {
    description = "Autoinstall NixOS shinji from embedded flake";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig.Type = "oneshot";
    path = [
      disko-pkg
      pkgs.nixos-install-tools
      pkgs.coreutils
      pkgs.util-linux
    ];
    script = ''
      if grep -q 'autoinstall' /proc/cmdline; then
        echo "==> Autoinstall triggered: partitioning /dev/nvme0n1..."
        disko --mode disko /etc/nixos/flake#shinji
        echo "==> Installing NixOS..."
        nixos-install --flake /etc/nixos/flake#shinji --root /mnt --no-root-passwd
        echo "==> Done! Rebooting in 5s..."
        sleep 5
        reboot -f
      fi
    '';
  };
}
