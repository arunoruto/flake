{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkEnableOption
    mkPackageOption
    mkOption
    types
    ;

  cfg = config.programs.vivid;
  yamlFormat = pkgs.formats.yaml { };
in
{
  meta.maintainers = [
    lib.hm.maintainers.aguirre-matteo
    lib.maintainers.arunoruto
  ];

  options.programs.vivid = {
    enable = mkEnableOption "vivid";
    package = mkPackageOption pkgs "vivid" { nullable = true; };

    colorMode = mkOption {
      type = with types; nullOr str;
      default = null;
      example = "8-bit";
      description = ''
        Color mode for vivid.
      '';
    };

    filetypes = mkOption {
      inherit (yamlFormat) type;
      default = { };
      example = {
        text = {
          special = [
            "CHANGELOG.md"
            "CODE_OF_CONDUCT.md"
            "CONTRIBUTING.md"
          ];

          todo = [
            "TODO.md"
            "TODO.txt"
          ];

          licenses = [
            "LICENCE"
            "COPYRIGHT"
          ];
        };
      };
      description = ''
        Filetype database for vivid. You can find an example config at:
        <https://github.com/sharkdp/vivid/blob/master/config/filetypes.yml>.
      '';
    };

    activeTheme = mkOption {
      type = types.str;
      default = "";
      example = "molokai";
      description = ''
        Active theme for vivid.
      '';
    };

    themes = mkOption {
      type = with types; attrsOf (either path yamlFormat.type);
      default = { };
      example = lib.literalExpression ''
        {
          ayu = builtins.fetchurl {
            url = "https://raw.githubusercontent.com/NearlyTRex/Vivid/refs/heads/master/themes/ayu.yml";
            hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };

          mocha = builtins.fetchurl {
            url = "https://raw.githubusercontent.com/NearlyTRex/Vivid/refs/heads/master/themes/catppuccin-mocha.yml";
            hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };

          my-custom-theme = {
            colors = {
              blue = "0000ff";
            };
            core = {
              directory = {
                foreground = "blue";
                font-style = "bold";
              };
            };
          };
        }
      '';
      description = ''
        An attribute set of vivid themes.
        Each value can either be a path to a theme file or an attribute set
        defining the theme directly (which will be converted from Nix to YAML).
      '';
    };

  };

  config = mkMerge [
    (mkIf (cfg.enable || cfg.themes != { }) {
      home.sessionVariables.LS_COLORS =
        let
          colorMode = lib.optionalString (cfg.colorMode != null) "-m ${cfg.colorMode}";
          themePath =
            if builtins.isAttrs cfg.themes.${cfg.activeTheme} then
              pkgs.writeText "${cfg.activeTheme}.json" (builtins.toJSON cfg.themes.${cfg.activeTheme})
            else if config.xdg.configFile ? "vivid/themes/${cfg.activeTheme}.yml" then
              config.xdg.configFile."vivid/themes/${cfg.activeTheme}.yml".source
            else
              cfg.activeTheme;
        in
        "$(cat ${
          pkgs.runCommand "ls-colors" {
            nativeBuildInputs = [ cfg.package ];
          } "vivid generate ${colorMode} ${themePath} > $out"
        })";
    })
    (mkIf cfg.enable {
      home.sessionVariables = mkIf (cfg.activeTheme != "") { VIVID_THEME = cfg.activeTheme; };

      xdg.configFile = {
        "vivid/filetypes.yml" = mkIf (cfg.filetypes != { }) {
          source = yamlFormat.generate "vivid-filetypes" cfg.filetypes;
        };
      }
      // (lib.mapAttrs' (
        name: value:
        lib.nameValuePair "vivid/themes/${name}.yml" (
          if lib.isAttrs value then
            { source = pkgs.writeText "${name}.json" (builtins.toJSON value); }
          else
            { source = value; }
        )
      ) cfg.themes);
    })
  ];
}
