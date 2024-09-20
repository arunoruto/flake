{
  # pkgs,
  lib,
  config,
  ...
}: {
  options.ppd.enable = lib.mkEnableOption ''
    Enable power saving using Power Profiles Deamon.
    Needed by AMD framework laptops, since TLP interfers with some process.
    https://knowledgebase.frame.work/en_us/optimizing-ubuntu-battery-life-Sye_48Lg3
  '';

  config = lib.mkIf config.ppd.enable {
    services.power-profiles-daemon.enable = lib.mkDefault true;
    powerManagement.powertop.enable = lib.mkDefault false;
    # environment.systemPackages = with pkgs; [
    #   powertop
    # ];
  };
}
