{
  config,
  lib,
  ...
}:
{
  imports = [
    # ./paper-stylix.nix
  ];

  options.hypr.paper.enable = lib.mkEnableOption "Configure hyprpaper for wallpaper settings";

  config = lib.mkIf config.hypr.paper.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        # preload = config.stylix.image;
        # wallpaper = ",${config.stylix.image}";
        splash = true;
        ipc = false;
      };
    };

    systemd.user.services.hyprpaper =
      let
        session = "hyprland-session.target";
      in
      {
        Install.WantedBy = lib.mkForce [ session ];
        Unit = {
          After = lib.mkForce [ session ];
          PartOf = lib.mkForce [ session ];
        };
      };
  };
}
