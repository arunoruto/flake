{
  config,
  # pkgs,
  ...
}:
{

  programs.atuin = {
    # package = pkgs.unstable.atuin;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      enter_accept = true;
      sync = {
        record = true;
        common_subcommands = [
          "apt"
          "dnf"
          "docker"
          "git"
          "go"
          "ip"
          "nix"
          "podman"
          "systemctl"
          "tmux"
        ];
      };
      theme.name = "stylix";
    };
  };

  home.file.".config/atuin/themes/stylix.toml".text = ''
    [theme]
    name = "stylix"

    [colors]
    # General UI elements
    Base = "${config.lib.stylix.colors.withHashtag.base03}"      # Darkest background
    Guidance = "${config.lib.stylix.colors.withHashtag.base05}"  # Main foreground text
    Title = "${config.lib.stylix.colors.withHashtag.base0D}"     # Primary accent color (Blue/Teal) for titles/headings
    Annotation = "${config.lib.stylix.colors.withHashtag.base04}" # Lighter gray for secondary text/annotations
    Important = "${config.lib.stylix.colors.withHashtag.base0E}" # Magenta/Pink for highlighted or important elements

    # Alert messages (using common semantic color assignments)
    AlertInfo = "${config.lib.stylix.colors.withHashtag.base0B}" # Green for success/info messages
    AlertWarn = "${config.lib.stylix.colors.withHashtag.base09}" # Orange for warning messages
    AlertError = "${config.lib.stylix.colors.withHashtag.base08}" # Red for error messages
  '';
}
