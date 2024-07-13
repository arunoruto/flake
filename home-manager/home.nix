{
  pkgs,
  lib,
  user,
  ...
}: {
  # Allow unfree software
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ./imports.nix
    ./stylix.nix
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    #username = builtins.getEnv "USER";
    #homeDirectory = builtins.getEnv "HOME";
    #username = ''${builtins.getEnv "USER"}'';
    #homeDirectory = ''${builtins.getEnv "HOME"}'';
    username = user;
    homeDirectory = "/home/${user}";
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  # This is now done in the respective client and server files
  #home.packages = with pkgs;
  #[
  #];

  ## Fonts
  #fonts.fonts = with pkgs; [
  #  aileron # helvetica
  #  liberation_ttf # Times New Roman, Arial, and Courier New
  #  (nerdfonts.override { fonts = [ "FiraCode" ]; })
  #];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".config/chrome-flags.conf".text = ''
      --enable-features=TouchpadOverscrollHistoryNavigation
      --enable-gpu-rasterization
      --ignore-gpu-blacklist
      --disable-gpu-driver-workarounds
    '';
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host kyuubi.tail
          HostName kyuubi
          User mar
          ForwardX11 yes
      Host ultron.tail
          Hostname ultron
          User mar
          ForwardX11 yes
      Host jabba.tail
          Hostname jabba
          User mar
          ForwardX11 yes
    '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mar/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "nvim";
    EDITOR = "hx";
    BROWSER = "firefox";
    WINIT_UNIX_BACKEND = "x11";
    FLAKE = "/home/${user}/.config/flake";
  };
}
