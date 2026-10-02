# https://danth.github.io/stylix/
# On NixOS/Darwin, stylix is configured at the system level and propagated
# into home-manager. For standalone home-manager (no osConfig) there is no
# system to inherit from, so we drive stylix here from the `theming` options,
# mirroring modules/nixos/system/theming.nix.
#
# ./targets holds stylix targets that upstream does not ship (yet), laid out
# exactly like upstream's modules/ tree:
#
#   targets/<target>/hm.nix     the target, written with `mkTarget`
#   targets/<target>/meta.nix   name, homepage, maintainers
#
# Upstreaming a target is `cp -r targets/<target> <stylix>/modules/`; nothing
# in it refers to this flake. Once stylix ships the target, delete the
# directory here (keeping both would declare `stylix.targets.<target>` twice).
#
# `mkTarget` is not exported by stylix; its autoloader hands it to
# modules/<target>/hm.nix. `loadTarget` below is a trimmed copy of
# stylix/autoload.nix + stylix/meta.nix (hm only) that does the same for
# ./targets, using the pinned stylix's own mk-target.nix and maintainers.nix.
{
  config,
  lib,
  pkgs,
  inputs,
  osConfig ? null,
  ...
}:
let
  stylixLib = "${inputs.stylix}/stylix";

  metaLib = lib.extend (
    _: prev: {
      maintainers = lib.attrsets.unionOfDisjoint prev.maintainers (import "${stylixLib}/maintainers.nix");
    }
  );

  loadTarget =
    target:
    let
      file = ./targets/${target}/hm.nix;
      module = import file;

      meta =
        let
          raw = import ./targets/${target}/meta.nix;
        in
        if builtins.isFunction raw then
          raw {
            inherit pkgs;
            lib = metaLib;
          }
        else
          raw;

      mkTarget = import "${stylixLib}/mk-target.nix" {
        humanName = meta.name;
        name = target;
      };

      useMkTarget = builtins.isFunction module && (builtins.functionArgs module) ? mkTarget;
    in
    if useMkTarget then
      { config, ... }@args:
      let
        context = name: ''while evaluating the module argument `${name}' in "${toString file}":'';
        extraArgs = lib.pipe module [
          builtins.functionArgs
          (lib.flip removeAttrs [ "mkTarget" ])
          (builtins.mapAttrs (
            name: _: builtins.addErrorContext (context name) (args.${name} or config._module.args.${name})
          ))
        ];
      in
      {
        key = file;
        _file = file;
        imports = [
          (module (
            args
            // extraArgs
            // {
              inherit mkTarget;
              config = lib.recursiveUpdate config {
                stylix = throw "stylix: unguarded `config.stylix` accessed while using mkTarget";
                lib.stylix.colors = throw "stylix: unguarded `config.lib.stylix.colors` accessed while using mkTarget";
              };
            }
          ))
        ];
      }
    else
      file;
in
{
  imports = lib.pipe (builtins.readDir ./targets) [
    (lib.filterAttrs (
      target: kind: kind == "directory" && builtins.pathExists ./targets/${target}/hm.nix
    ))
    builtins.attrNames
    (map loadTarget)
  ];

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
