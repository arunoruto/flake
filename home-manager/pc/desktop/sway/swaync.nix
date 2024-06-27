let
  version = "0.2.2";
  flavor = "macchiato";
  catppuccin-swaync = "";
  # catppuccin-swaync = builtins.fetchurl {
  #   url = "https://github.com/catppuccin/swaync/releases/download/${version}/${flavor}.css";
  #   hash = "";
  # };
in {
  programs.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "bottom";
      layer = "overlay";
    };
  };
  # home.file.".config/swaync/style.css".source = "${catppuccin-swaync}";
}
