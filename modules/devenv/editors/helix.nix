{
  pkgs,
  lib,
  config,
  ...
}:
let
  tomlFormat = pkgs.formats.toml { };
  helixLib = import ../lib/helix.nix { inherit lib; };

  # Filter enabled languages
  activeLanguages = lib.filterAttrs (n: v: v.enable) config.development.languages;

  # Use pure functions to transform data
  extractedPackages = helixLib.extractPackages activeLanguages;
  translatedLanguages = helixLib.toHelixLanguages activeLanguages;
  translatedLspConfigs = helixLib.toHelixLspConfigs activeLanguages;
in
{
  options.programs.helix = {
    enable = lib.mkEnableOption "Helix text editor";

    package = lib.mkPackageOption pkgs "helix" { };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra lines to be appended to the config file.
        Use this if you would like to maintain order for helix settings.
      '';
      example = lib.literalExpression ''
        [keys.normal.g]
        G = "goto_file_end"
        g = "goto_file_start"
      '';
    };

    settings = lib.mkOption {
      inherit (tomlFormat) type;
      default = { };
      description = ''
        Configuration written to `.helix/config.toml`.
      '';
    };

    languages = lib.mkOption {
      type =
        with lib.types;
        coercedTo (listOf tomlFormat.type) (
          language:
          lib.warn ''
            The syntax of programs.helix.languages has changed.
            It now generates the whole languages.toml file instead of just the language array.
            Use programs.helix.languages = { language = <languages list>; } instead.
          '' { inherit language; }
        ) (addCheck tomlFormat.type builtins.isAttrs);
      default = { };
      description = ''
        Language specific configuration written to `.helix/languages.toml`.
      '';
    };
  };

  config =
    let
      cfg = config.programs.helix;

      hasSettings = cfg.settings != { };
      hasExtraConfig = cfg.extraConfig != "";
    in
    lib.mkIf cfg.enable {
      packages = [ cfg.package ] ++ extractedPackages;

      programs.helix.languages = lib.mkMerge [
        (lib.mkIf (translatedLanguages != [ ]) { language = translatedLanguages; })
        translatedLspConfigs
      ];

      files = lib.mkMerge [
        # 1. Main config.toml
        (lib.mkIf (hasSettings || hasExtraConfig) {
          ".helix/config.toml".source = pkgs.runCommand "helix-config.toml" { } ''
            cat ${tomlFormat.generate "config.toml" cfg.settings} > $out
            ${lib.optionalString hasExtraConfig ''
              echo "" >> $out
              cat ${pkgs.writeText "extra.toml" cfg.extraConfig} >> $out
            ''}
          '';
        })

        # 2. Languages config
        (lib.mkIf (cfg.languages != { }) {
          ".helix/languages.toml".source = tomlFormat.generate "helix-languages.toml" cfg.languages;
        })
      ];

      infoSections."Helix" = [
        "Package: ${cfg.package.name}"
      ]
      ++ lib.optional (hasSettings || hasExtraConfig) "Config: .helix/config.toml"
      ++ lib.optional (cfg.languages != { }) "Languages: .helix/languages.toml";
    };
}
