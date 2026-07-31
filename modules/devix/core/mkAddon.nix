# Turn the pure data in addons/<name>.nix into a `devix.addons.<name>`
# option module. Called once per data file by addons/default.nix.
#
# An addon is a group of language servers that is not itself a language:
# spell/grammar checking, AI completion, and so on. It contributes its servers
# to real languages instead of pretending to be one, which is what keeps them
# out of an editor's language list.
{
  name,
  dataPath,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  consumers = import ../consumers/registry.nix { inherit lib; };
  data = import dataPath { inherit lib pkgs; };
  cfg = config.devix.addons.${name};

  # Populate the shared devix.lsps registry from this addon's data, every
  # value as mkDefault so users can override.
  registryDefs = lib.flatten (
    lib.mapAttrsToList (
      itemName: itemValue:
      lib.mapAttrsToList (optName: optValue: {
        devix.lsps.${itemName}.${optName} = lib.mkDefault optValue;
      }) itemValue
    ) (data.lsps or { })
  );
in
{
  options.devix.addons.${name} = lib.mkOption {
    default = { };
    description = ''
      Settings for the ${name} addon (${data.description or "the ${name} addon"}),
      defaulted from `modules/devix/addons/${name}.nix`. An addon contributes its
      language servers to the languages it names instead of being a language.
    '';
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption (data.description or "the ${name} addon");

        lspServers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = data.lspServers or (lib.attrNames (data.lsps or { }));
          description = ''
            Language servers (keys into devix.lsps) this addon attaches.
            The addon may define more servers than it attaches — the extras stay
            available in the registry for you to opt into.
          '';
        };

        languages = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = data.languages or [ "*" ];
          example = [
            "markdown"
            "latex"
          ];
          description = ''
            Languages these servers attach to, keyed by
            `devix.languages.<name>`. The single entry "*" attaches to
            every enabled language.
          '';
        };

        consumers = consumers.mkExposureOption ''
          Per-consumer exposure for the ${name} addon. Each consumer defaults to
          enabled; set e.g. `consumers.zed.enable = false` to keep this addon's
          servers out of Zed only.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge registryDefs);
}
