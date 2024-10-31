{
  config,
  lib,
  ...
}:
let
  version = "0.2.2";
  flavor = "macchiato";
  catppuccin-swaync = "";
in
# catppuccin-swaync = builtins.fetchurl {
#   url = "https://github.com/catppuccin/swaync/releases/download/${version}/${flavor}.css";
#   hash = "";
# };
{
  options.sway.notify.enable = lib.mkEnableOption "Custom sway notification";

  config = lib.mkIf config.sway.notify.enable {
    programs.swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "bottom";
        layer = "overlay";
      };
    };
    # home.file.".config/swaync/style.css".source = "${catppuccin-swaync}";
  };
}
