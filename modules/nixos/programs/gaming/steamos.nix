# Adapter for the steamos flake (steamos/, consumed as an input and wired
# into every host by systems/default.nix): the mechanism lives there with no
# dependency on this flake; the glue to our conventions lives here.
{
  config,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    {
      # The one human this machine belongs to is also the one holding the
      # controller.
      steamos.user = lib.mkDefault config.users.primaryUser;
    }

    (lib.mkIf (config.steamos.enable && config.steamos.autoStart) {
      # steamos owns the login path with greetd (aliased to
      # display-manager.service), so GDM, which the desktop tag turns on by
      # default, must stay out of the way. The desktop environment itself
      # stays enabled — it is what Desktop Mode switches to.
      services.displayManager.gdm.enable = false;
    })
  ];
}
