# programs.tuios — home-manager has no module for tuios yet, so this declares
# one in the shape upstream modules usually take (enable/package/settings).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;

  cfg = config.programs.tuios;

  tomlFormat = pkgs.formats.toml { };
  jsonFormat = pkgs.formats.json { };
in
{
  options.programs.tuios = {
    enable = lib.mkEnableOption "tuios, a terminal window manager";

    package = lib.mkPackageOption pkgs "tuios" { nullable = true; };

    settings = mkOption {
      inherit (tomlFormat) type;
      default = { };
      example = {
        appearance = {
          border_style = "rounded";
          dockbar_position = "top";
          theme = "dracula";
        };
        keybindings.leader_key = "ctrl+space";
      };
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/tuios/config.toml`.
        Run `tuios config reset` against a scratch config to see every key
        and its default.
      '';
    };

    themes = mkOption {
      type = types.attrsOf (types.either types.path jsonFormat.type);
      default = { };
      example = {
        my-theme = {
          fg = "#e5e5e5";
          bg = "#101014";
          red = "#e06c75";
        };
      };
      description = ''
        Custom themes written to {file}`$XDG_CONFIG_HOME/tuios/themes/<name>.json`.
        The attribute name is used as the theme `id`, so it is what
        {option}`programs.tuios.settings.appearance.theme` refers to.
        A path is linked as-is.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf (cfg.package != null) [ cfg.package ];

    xdg.configFile = {
      "tuios/config.toml" = mkIf (cfg.settings != { }) {
        source = tomlFormat.generate "tuios-config.toml" cfg.settings;
      };
    }
    // lib.mapAttrs' (
      name: theme:
      lib.nameValuePair "tuios/themes/${name}.json" {
        source =
          if lib.isPath theme || lib.isString theme then
            theme
          else
            jsonFormat.generate "tuios-theme-${name}.json" ({ id = name; } // theme);
      }
    ) cfg.themes;
  };
}
