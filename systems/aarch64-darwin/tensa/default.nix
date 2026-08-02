{
  pkgs,
  ...
}:
{
  system.tags = [
    "desktop"
    "laptop"
    "development"
  ];

  # System packages
  environment.systemPackages =
    (with pkgs; [
      direnv
      helix
      iproute2mac
      nh
      git-quill
    ])
    ++ (with pkgs.unstable; [
      devenv
    ]);

  # Primary user configuration (shared between NixOS and Darwin)
  users.primaryUser = "mirza";

  # Stylix theming configuration
  stylix = {
    image = ../../../modules/home-manager/theming/wallpaper.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    polarity = "dark";
  };

  # Tiling window manager. yabai tiles inside native macOS Spaces, so the
  # Desktops in Mission Control keep working; AeroSpace (the alternative in
  # modules/darwin/services/window-manager/) replaces Spaces instead and would
  # fight them. Enabling both trips an assertion.
  #
  # skhd, the hotkey daemon, comes with it — chord is ctrl+alt.
  services.yabai = {
    # enable = true;
    config = {
      # Roomier than the module default; the built-in 3024x1964 panel has the
      # pixels to spare.
      top_padding = 12;
      bottom_padding = 12;
      left_padding = 12;
      right_padding = 12;
      window_gap = 12;
    };
  };

  # Darwin-specific modules configuration
  homebrew = {
    enable = true;
    user = "mirza";
    casks = [
      "caffeine"
      "telegram"
      "rnote"
      "visual-studio-code"
      "zed"
      "zoom"
    ];
  };

  # State version
  system.stateVersion = 6;
}
