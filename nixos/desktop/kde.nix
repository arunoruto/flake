{pkgs, ...}: {
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
}
