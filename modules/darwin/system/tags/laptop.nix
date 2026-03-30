{ lib, config, ... }:
{
  config = lib.mkIf (lib.elem "laptop" config.system.tags) {
    # Darwin laptop-specific configurations (battery, power management, etc.)
  };
}
