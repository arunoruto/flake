{ lib, config, ... }:
{
  config = lib.mkIf (lib.elem "desktop" config.system.tags) {
    # Darwin-specific desktop configurations can go here
    # Main purpose is home-manager propagation via system.tags
  };
}
