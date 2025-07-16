{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.services.tlp.enable {
    # Enable TLP and powertop for better battery life
    services = {
      # PPD and TLP don't work together!
      # power-profiles-daemon.enable = lib.mkForce false;
      tlp.settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        PCIE_ASPM_ON_BAT = "powersupersave";
        RESTORE_DEVICE_STATE_ON_STARTUP = 1;
        RUNTIME_PM_ON_BAT = "auto";

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;

        # Optional helps save long term battery health
        # START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
        # STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
      };
    };
    powerManagement.powertop.enable = true;
  };
}
