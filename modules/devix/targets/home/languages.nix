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
  missingFormatters = builtins.filter (
    name: !(builtins.hasAttr name cfg.formatters)
  ) referencedFormatters;

  enabledPackage =
    registry: name:
    if
      builtins.hasAttr name registry && registry.${name}.enable && registry.${name}.package != null
    then
      [ registry.${name}.package ]
    else
      [ ];

  # Tools that Home Manager may already manage via a `programs.<tool>` module.
  # When such a program is enabled we install ITS package instead of the
  # devix-registry one, giving a single source of truth and avoiding duplicate
  # or version-divergent installs. Keyed by the package `pname`; extend this map
  # as more managed tools are adopted.
  managedBy = {
    ruff = config.programs.ruff or { };
  };

  # If a package's tool is managed by an enabled program, prefer that program's
  # package; otherwise keep the devix-provided one.
  preferManaged =
    pkg:
    let
      prog = managedBy.${pkg.pname or ""} or null;
    in
    if prog != null && (prog.enable or false) && (prog.package or null) != null then
      prog.package
    else
      pkg;
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

    home.packages =
      let
        packages =
          lib.concatMap (enabledPackage cfg.lsps) referencedLsps
          ++ lib.concatMap (enabledPackage cfg.formatters) referencedFormatters;
      in
      lib.unique (map preferManaged packages);
  };
}
