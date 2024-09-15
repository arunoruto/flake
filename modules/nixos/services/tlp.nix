{
  lib,
  config,
  ...
}: {
  options.tlp.enable = lib.mkEnableOption "Enable power saving using TLP";

  config = lib.mkIf config.tlp.enable {
    # Enable TLP and powertop for better battery life
    services = {
      power-profiles-daemon.enable = false;
      tlp = {
        enable = true;
        settings = {
          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          PCIE_ASPM_ON_BAT = "powersupersave";
          RESTORE_DEVICE_STATE_ON_STARTUP = 1;
          RUNTIME_PM_ON_BAT = "auto";
        };
      };
    };
    powerManagement.powertop.enable = true;
  };
}
