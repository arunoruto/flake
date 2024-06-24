{pkgs, ...}: {
  #environment.systemPackages = with pkgs; [
  #  dbus   # make dbus-update-activation-environment available in the path
  #  dbus-sway-environment
  #  configure-gtk
  #  grim # screenshot functionality
  #  slurp # screenshot functionality
  #  wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
  #  mako # notification system developed by swaywm maintainer
  #  wdisplays # tool to configure displays
  #];

  #services.dbus.enable = true;
  #xdg.portal = {
  #  enable = true;
  #  wlr.enable = true;
  #  # gtk portal needed to make gtk apps happy
  #  #extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  #};

  programs = {
    # Enable hyprland and xwayland
    hyprland = {
      enable = true;
      # package = pkgs.unstable.hyprland;
      xwayland.enable = true;
    };
    # If you are on a laptop, you can set up brightness and volume function keys as follows:
    light.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hyprpaper
    hyprlock
  ];
}
