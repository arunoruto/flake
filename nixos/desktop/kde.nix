{
  config,
  lib,
  # pkgs,
  ...
}: {
  options = {
    kde.enable = lib.mkEnableOption "Use the KDE desktop environment";
  };

  config = lib.mkIf config.kde.enable {
    services = {
      desktopManager.plasma6.enable = true;
    };

    security.pam.services.kwallet = {
      name = "kwallet";
      enableKwallet = true;
    };

    # services.xserver.displayManager.sddm.enable = true;

    # environment.gnome.excludePackages =
    #   (with pkgs; [
    #     ])
    #   ++ (with pkgs.gnome; [
    #     ]);
  };
}
