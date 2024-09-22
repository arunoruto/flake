{pkgs, ...}: {
  imports = [
    ./chrome.nix
  ];

  environment = {
    # Enable shells
    shells = with pkgs; [zsh];
    pathsToLink = ["/share/zsh"];

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      clinfo
      dig
      direnv
      ffmpeg
      file
      git
      htop
      imagemagickBig
      iperf
      killall
      nmap
      ntfs3g
      usbutils
      pciutils
      powertop
      tlrc
      traceroute
      unzip

      bat
      dust
      eza
      # linuxPackages_latest.perf
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

      discord
      gthumb
      # jabref
      libsForQt5.kdenlive
      libsForQt5.okular
      #mailspring
      # masterpdfeditor
      # mprime
      unstable.plex-desktop
      remmina
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
}
