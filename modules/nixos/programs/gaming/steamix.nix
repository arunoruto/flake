# Adapter for Steamix (github.com/arunoruto/steamix, the `steamix` input):
# the mechanism lives there with no dependency on this flake; the glue to our
# conventions lives here.
#
# Only hosts that import inputs.steamix.nixosModules.default have the
# steamix.* options, so this applies only there. Checking `options` rather
# than `config` keeps the guard free of recursion: declarations never depend
# on configuration.
{
  config,
  lib,
  options,
  ...
}:
{
  config = lib.optionalAttrs (options ? steamix) (
    lib.mkMerge [
      {
        # The one human this machine belongs to is also the one holding the
        # controller.
        steamix.user = lib.mkDefault config.users.primaryUser;
      }

      (lib.mkIf (config.steamix.enable && config.steamix.autoStart) {
        # steamix owns the login path with greetd (aliased to
        # display-manager.service), so GDM, which the desktop tag turns on by
        # default, must stay out of the way. The desktop environment itself
        # stays enabled — it is what Desktop Mode switches to.
        services.displayManager.gdm.enable = false;
      })
    ]
  );
}
