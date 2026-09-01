# Generated steamos documentation: the option reference, built from the
# option descriptions in modules/steamos exactly as ./devix-reference.nix does
# for devix — so the two cannot drift from their modules the way hand-written
# pages do.
#
# One difference in technique: devix evaluates against a shim declaring the
# handful of Home Manager options it writes to. steamos writes to far too much
# of NixOS for a shim to be honest (display managers, PAM, polkit, systemd,
# sysctl, ...), so the module system's unmatched-definition check is switched
# off instead. Only `options.steamos` is rendered either way, and the config
# side is never forced, so nothing outside the option declarations has to
# resolve.
{
  lib,
  pkgs,
  runCommand,
  nixosOptionsDoc,
}:
let
  repoRoot = toString ../.. + "/";
  repoUrl = "https://github.com/arunoruto/flake/blob/main";

  evaluated = lib.evalModules {
    modules = [
      ../../modules/steamos
      { _module.check = false; }
    ];
    specialArgs = { inherit pkgs; };
  };

  # Link each option back to the file that declares it.
  transformOptions =
    option:
    option
    // {
      declarations = map (
        declaration:
        let
          # Modules imported as a directory declare their options against the
          # directory; point at the file that actually holds them.
          path =
            if builtins.pathExists (declaration + "/default.nix") then
              "${toString declaration}/default.nix"
            else
              toString declaration;
          subPath = lib.removePrefix repoRoot path;
        in
        {
          name = subPath;
          url = "${repoUrl}/${subPath}";
        }
      ) option.declarations;
    };

  body =
    (nixosOptionsDoc {
      options.steamos = evaluated.options.steamos;
      inherit transformOptions;
    }).optionsCommonMark;

  page = runCommand "steamos-options.md" { } ''
    {
      printf '%s\n\n' '# Option reference'
      printf '%s\n\n' ${lib.escapeShellArg ''
        Every `steamos.*` option, generated from the declarations in
        `modules/steamos`. The [Options](../options.md) page is the curated
        tour — what to reach for and why; this page is the complete,
        cannot-drift listing.
      ''}
      cat ${body}
    } > $out
  '';
in
runCommand "steamos-reference" { } ''
  mkdir -p $out
  cp ${page} $out/options.md
''
