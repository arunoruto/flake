{ lib, config, ... }:
{
  config = lib.mkIf (config.lib.tags.hasTag "desktop") {
    # Darwin-specific desktop configurations can go here
    # Main purpose is home-manager propagation via system.tags
  };
}
