{
  pkgs,
  lib,
  ...
}:
#let
#  unstable = import
#    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable)
#    # reuse the current configuration
#    { config = config.nixpkgs.config; };
#in
{
  #imports = [
  #  <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
  #];

  # Enable firmware updates
  services.fwupd.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.job.preStart = "sleep 3";
  # Gnome Keyring
  services.gnome.gnome-keyring.enable = true;

  # Enbale leftwm
  services.xserver.windowManager.leftwm.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "de";
    xkbVariant = "";
  };

  # Remove included X11 packages
  services.xserver.excludePackages = [pkgs.xterm];

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      brlaser
      brgenml1lpr
      brgenml1cupswrapper
    ];
  };
  # Enable SANE for scanning documents.
  hardware.sane = {
    enable = true;
    #extraBackends = [
    #  pkgs.sane-airscan
    #];
    # https://github.com/NixOS/nixpkgs/issues/273280#issuecomment-1848875571
    # Needs NixOS 24.05 or higher
    #backends-package = pkgs.sane-backends.overrideAttrs (old: {
    #  configureFlags = (old.configureFlags or []) ++ [
    #    "--disable-locking"
    #  ];
    #});
    #brscan4 = {
    #  enable = true;
    #};
  };
  # If the scanner is connected via USB
  services.ipp-usb.enable = true;
  # Disable locking entirely (takes really long to compile)
  #nixpkgs.overlays = [
  #  (final: prev: {
  #    # Fixes a problem that attempt to access /nix/store/.../var/lock .
  #    # Without this, the scanner is not detected.
  #    sane-backends = prev.sane-backends.overrideAttrs
  #      ({ configureFlags ? [ ], ... }: {
  #        configureFlags = configureFlags ++ [ "--disable-locking" ];
  #      });
  #  })
  #];

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  programs.zsh.enable = true;

  # Packages with udev rules
  services.udev = {
    packages = with pkgs; [
      vial
    ];
    extraRules = ''
      # Vial support
      # https://get.vial.today/manual/linux-udev.html
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      # Fix headphone noise when on powersave
      # https://community.frame.work/t/headphone-jack-intermittent-noise/5246/55
      SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0xa0e0", ATTR{power/control}="on"
      # Ethernet expansion card support
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156", ATTR{power/autosuspend}="20"
    '';
  };

  # Flatpak for more package potions
  services.flatpak.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable fingerprint support with goodix (framework)
  services.fprintd.enable = true;
  #systemd.services.fprintd.after = [ "display-manager.service" ];

  services.fstrim.enable = lib.mkDefault true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Resolve .local
  #services.avahi.enable = true;
  #services.avahi.nssmdns = false;
  # this is what avahi.nssmdns does, but mdns4 (IPv4) instead of mdns (dual-stack)
  system.nssModules = pkgs.lib.optional true pkgs.nssmdns;
  system.nssDatabases.hosts = pkgs.lib.optionals true (pkgs.lib.mkMerge [
    (pkgs.lib.mkBefore ["mdns4_minimal [NOTFOUND=return]"]) # before resolve
    (pkgs.lib.mkAfter ["mdns4"]) # after dns
  ]);
  services.avahi = {
    enable = true;
    ipv6 = false;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
    nssmdns = true;
    openFirewall = true;
  };

  # Enable tailscale
  services.tailscale = {
    enable = true;
    port = 41641;
    useRoutingFeatures = "client";
    package = pkgs.unstable.tailscale;
    extraUpFlags = [
      "--accept-routes"
    ];
  };
}
