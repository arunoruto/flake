{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.xserver.displayManager.lightdm.enable {
    services.xserver.displayManager.lightdm = {
      # background = lib.mkForce /home/mirza/Pictures/wallpapers/art/kanagawa/kanagawa-van-gogh.jpg;
      # background = lib.mkForce config.stylix.image;
      greeters = {
        gtk = {
          enable = true;
          theme = {
            # name = "Catppuccin-Macchiato-Standard-Green-dark";
            # package = pkgs.catppuccin-gtk;
          };
          cursorTheme = {
            name = "Catppuccin-Macchiato-Dark-Cursors";
            size = 24;
          };
          # iconTheme = {
          #   name = "candy-icons";
          #   package = pkgs.candy-icons;
          # };
        };

        tiny = {
          enable = false;
          # extraConfig = "";
        };
      };
      # displayManager.preStart = "sleep 1";
    };

    programs.ssh.askPassword = lib.mkForce "${pkgs.gnome.seahorse.out}/bin/seahorse";

    environment.systemPackages = with pkgs; [
      lightdm-gtk-greeter
      lightdm-tiny-greeter
    ];
  };
}
