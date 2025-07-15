{
  # pkgs,
  lib,
  config,
  ...
}:
{
  # Enable power saving using Power Profiles Deamon.
  # Needed by AMD framework laptops, since TLP interfers with some process.
  # https://knowledgebase.frame.work/en_us/optimizing-ubuntu-battery-life-Sye_48Lg3

  config = lib.mkIf config.services.power-profiles-daemon.enable {
    # services.tlp.enable = false;
    powerManagement.powertop.enable = lib.mkDefault false;
    # environment.systemPackages = with pkgs; [
    #   powertop
    # ];
  };
}
