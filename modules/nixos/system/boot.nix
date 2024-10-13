{
  pkgs,
  lib,
  ...
}: {
  boot = {
    loader = {
      timeout = lib.mkDefault 0; # Hit F10 for a list of generations
      systemd-boot = {
        enable = lib.mkDefault true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = lib.mkDefault true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    #boot.plymouth = {
    #  enable = true;
    #  #theme = "catppuccin-macchiato";
    #  #themePackages = with pkgs; [ catppuccin-plymouth ];
    #};
  };
}
