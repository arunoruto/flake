{
  config,
  lib,
  ...
}:

let
  cfg = config.development;
  enabledLanguages = lib.filterAttrs (_: language: language.enable) cfg.languages;
  referencedLsps = lib.sort lib.lessThan (
    lib.unique (lib.concatMap (language: language.lspServers) (lib.attrValues enabledLanguages))
  );
  referencedFormatters = lib.sort lib.lessThan (
    lib.unique (lib.concatMap (language: language.formatters) (lib.attrValues enabledLanguages))
  );

  missingLsps = builtins.filter (name: !(builtins.hasAttr name cfg.lsps)) referencedLsps;
  missingFormatters = builtins.filter (name: !(builtins.hasAttr name cfg.formatters)) referencedFormatters;

  enabledPackage = registry: name:
    if builtins.hasAttr name registry && registry.${name}.enable && registry.${name}.package != null then
      [ registry.${name}.package ]
    else
      [ ];
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = missingLsps == [ ];
        message = "development.languages references unknown LSPs: ${lib.concatStringsSep ", " missingLsps}";
      }
      {
        assertion = missingFormatters == [ ];
        message = "development.languages references unknown formatters: ${lib.concatStringsSep ", " missingFormatters}";
      }
    ];

    home.packages = lib.unique (
      lib.concatMap (enabledPackage cfg.lsps) referencedLsps
      ++ lib.concatMap (enabledPackage cfg.formatters) referencedFormatters
    );
  };
}
