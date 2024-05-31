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
      hunspell
      hunspellDicts.de_DE
      hunspellDicts.en_US
      jabref
      libreoffice-qt
      libsForQt5.kdenlive
      libsForQt5.okular
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
}
