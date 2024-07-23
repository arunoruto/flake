{pkgs, ...}: {
  boot = {
    loader = {
      timeout = 0; # Hit F10 for a list of generations
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    #boot.plymouth = {
    #  enable = true;
    #  #theme = "catppuccin-macchiato";
    #  #themePackages = with pkgs; [ catppuccin-plymouth ];
    #};
    kernel.sysctl = {
      # https://github.com/tailscale/tailscale/issues/3310#issuecomment-1722601407
      "net.ipv4.conf.eth0.rp_filter" = 2;
    };
  };
}
