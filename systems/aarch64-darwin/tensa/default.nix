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
