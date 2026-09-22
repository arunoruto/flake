# https://danth.github.io/stylix/
# On NixOS/Darwin, stylix is configured at the system level and propagated
# into home-manager. For standalone home-manager (no osConfig) there is no
# system to inherit from, so we drive stylix here from the `theming` options,
# mirroring modules/nixos/system/theming.nix.
{
  config,
  lib,
  pkgs,
  inputs,
  osConfig ? null,
  ...
}:
{
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = config ? stylix;
          message = ''
            Stylix is not configured! Please add to your configuration:

            For NixOS:
              imports = [ inputs.stylix.nixosModules.stylix ];

            For Darwin:
              imports = [ inputs.stylix.darwinModules.stylix ];

            For standalone home-manager:
              imports = [ inputs.stylix.homeModules.stylix ];
          '';
        }
      ];
    }

    # Stylix enables its KDE target whether or not Plasma exists: it installs
    # a look-and-feel package, runs plasma-apply-lookandfeel on every
    # activation and prepends a kdeglobals dir to XDG_CONFIG_DIRS. Tie it to
    # the Plasma session when there is a system to ask. (Qt apps are themed by
    # the separate qt target either way.)
    (lib.mkIf (osConfig != null) {
      stylix.targets.kde.enable = lib.mkDefault (
        osConfig.services.desktopManager.plasma6.enable or false
      );
    })

    # Standalone home-manager only: map the theming options onto stylix the
    # same way the NixOS system module does. Under NixOS/Darwin these come
    # from the system, so we must not set them here (osConfig != null).
    (lib.mkIf (osConfig == null) {
      stylix = {
        enable = lib.mkDefault true;
        base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${config.theming.scheme}.yaml";
        image = lib.mkDefault (inputs.wallpapers + "/${config.theming.image}");
        polarity = lib.mkDefault "dark";
      };
    })
  ];
}
