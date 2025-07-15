{ lib, config, ... }:
{
  config = lib.mkIf config.services.auto-cpufreq.enable {
    services.auto-cpufreq.settings = lib.mkDefault {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
}
