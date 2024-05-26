{
  config,
  pkgs,
  lib,
  ...
}: {
  # Allow unfree packages
  # nixpkgs.config = {
  #   allowUnfree = true;
  #   packageOverrides = pkgs: {
  #     unstable = import <nixpkgs-unstable> {
  #       config = config.nixpkgs.config;
  #     };
  #     nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #       inherit pkgs;
  #     };
  #   };
  # };

  # Fonts
  fonts.packages = with pkgs; [
    aileron # helvetica
    jetbrains-mono
    liberation_ttf # Times New Roman, Arial, and Courier New
    (nerdfonts.override {fonts = ["FiraCode"];})
    noto-fonts-color-emoji
  ];

  environment = {
    # Enable shells
    shells = with pkgs; [zsh];
    pathsToLink = ["/share/zsh"];

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      # nix tools
      nix-tree
      nix-output-monitor
      # nvd

      btop
      clinfo
      dig
      direnv
      ffmpeg
      file
      git
      htop
      imagemagick
      intel-gpu-tools
      iperf
      killall
      nmap
      ntfs3g
      usbutils
      pciutils
      powertop
      tlrc
      traceroute

      cargo
      gcc
      gcc-unwrapped
      gnumake
      julia-bin
      python3
      #unstable.ruff
      rustc
      #ruff

      bat
      du-dust
      eza
      linuxPackages_latest.perf
      lsd
      riffdiff
      tmux
      unstable.ventoy
      vim
      vlc
      unstable.vscode
      #vscode
      wezterm
      wget
      wl-clipboard
      unstable.zed-editor

      discord
      firefox
      gthumb
      (google-chrome.override {
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation,UseOzonePlatform"
          "--ozone-platform=wayland"
          #"--enable-gpu-rasterization"
          #"--ignore-gpu-blacklist"
          #"--disable-gpu-driver-workarounds"
        ];
      })
      hunspell
      hunspellDicts.de_DE
      hunspellDicts.en_US
      jabref
      libreoffice-qt
      libsForQt5.kdenlive
      #mailspring
      masterpdfeditor
      mprime
      remmina
      thunderbird
      zoom-us
      zotero

      texlive.combined.scheme-full

      #ultrastardx
      #ultrastar-manager

      # Gnome specific applications
      nautilus-open-any-terminal
      gnome.nautilus-python
      gnome.gnome-software
      gnome.pomodoro
      gnome.gnome-remote-desktop
      gnome3.gnome-tweaks
    ];
  };

  #programs.nix-ld = {
  #  enable = true;
  #  libraries = with pkgs; [
  #    stdenv.cc.cc
  #    zlib
  #  ];
  #};

  # Enable native Wayland support for chrome/electron
  #environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs.hyprland = {
    package = pkgs.unstable.hyprland;
  };
}
