# Adapter for modules/steamos (the reusable Steam-machine module): the
# mechanism lives there with no dependency on this flake; the glue to our
# conventions lives here.
{
  config,
  lib,
  ...
}:
{
  imports = [ ../../../steamos ];

  config = lib.mkMerge [
    {
      # The one human this machine belongs to is also the one holding the
      # controller.
      steamos.user = lib.mkDefault config.users.primaryUser;
    }

    (lib.mkIf (config.steamos.enable && config.steamos.autoStart) {
      # steamos owns the login path with greetd (aliased to
      # display-manager.service), so the desktop tag's display manager must
      # stay out of the way. The desktop environment itself stays enabled —
      # it is what Desktop Mode switches to.
      display-manager.enable = false;
    })
  ];
}
