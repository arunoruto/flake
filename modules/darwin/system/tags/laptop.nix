{ lib, config, ... }:
{
  config = lib.mkIf (config.lib.tags.hasTag "laptop") {
    # Darwin laptop-specific configurations (battery, power management, etc.)
  };
}
