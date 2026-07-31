# Generated devix documentation: the option reference (built from the option
# descriptions in modules/devix) and the language/consumer support matrix.
#
# Modelled on how Stylix builds its reference — evaluate the modules in
# isolation with `lib.evalModules` plus a small shim declaring the host options
# devix writes to, then render with `nixosOptionsDoc`. Nothing here needs a real
# system, or home-manager itself.
#
# The output is a directory of markdown pages, dropped into docs/devix/reference
# by packages/docs/package.nix (and by `just docs` for local previews).
{
  lib,
  pkgs,
  runCommand,
  writeText,
  nixosOptionsDoc,
}:
let
  devix = ../../modules/devix;
  repoRoot = toString ../.. + "/";
  repoUrl = "https://github.com/arunoruto/flake/blob/main";

  # devix writes to a handful of Home Manager options. Declaring them here lets
  # the modules evaluate on their own, without pulling in home-manager.
  hostCompat = {
    options = {
      home = {
        packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          visible = false;
        };
        sessionVariables = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          visible = false;
        };
      };
      programs = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        visible = false;
      };
      assertions = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [ ];
        visible = false;
      };
      warnings = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        visible = false;
      };
    };
  };

  evaluated = lib.evalModules {
    modules = [
      (devix + "/targets/home")
      hostCompat
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

  # One reference page per group of top-level devix options.
  mkPage =
    {
      title,
      intro,
      attrs,
    }:
    let
      body =
        (nixosOptionsDoc {
          options.devix = lib.filterAttrs (name: _: builtins.elem name attrs) evaluated.options.devix;
          inherit transformOptions;
        }).optionsCommonMark;
    in
    runCommand "devix-options-${lib.toLower (lib.head (lib.splitString " " title))}.md" { } ''
      {
        printf '%s\n\n' '# ${title}'
        printf '%s\n\n' ${lib.escapeShellArg intro}
        cat ${body}
      } > $out
    '';

  pages = {
    "core.md" = mkPage {
      title = "Core options";
      intro = "The top-level switches: whether devix is active, how consumers attach themselves, and which editor becomes `EDITOR`.";
      attrs = [
        "enable"
        "autoEnable"
        "defaultEditor"
        "consumers"
      ];
    };

    "languages.md" = mkPage {
      title = "Language options";
      intro = "One entry per file in `modules/devix/languages/`. Everything except `enable` is defaulted from that file, so you only need to override what you want to change.";
      attrs = [ "languages" ];
    };

    "addons.md" = mkPage {
      title = "Addon options";
      intro = "One entry per file in `modules/devix/addons/`. An addon contributes language servers to the languages it names rather than being a language itself.";
      attrs = [ "addons" ];
    };

    "registries.md" = mkPage {
      title = "Registry options";
      intro = "The shared language-server and formatter registries. Languages and addons refer to entries here by name, so overriding one entry changes it for every editor at once.";
      attrs = [
        "lsps"
        "formatters"
      ];
    };
  };

  # ---------------------------------------------------------------- matrix --

  readNames =
    dir:
    map (lib.removeSuffix ".nix") (
      lib.attrNames (
        lib.filterAttrs (
          fileName: type: type == "regular" && fileName != "default.nix" && lib.hasSuffix ".nix" fileName
        ) (builtins.readDir dir)
      )
    );

  registry = import (devix + "/consumers/registry.nix") { inherit lib; };

  languageNames = readNames (devix + "/languages");
  addonNames = readNames (devix + "/addons");

  languageData = name: import (devix + "/languages/${name}.nix") { inherit lib pkgs; };
  addonData = name: import (devix + "/addons/${name}.nix") { inherit lib pkgs; };

  code = items: if items == [ ] then "—" else lib.concatMapStringsSep ", " (item: "`${item}`") items;

  # A consumer covers a language if it configures languages generically, or if
  # the language carries metadata for it.
  coverage =
    consumer: data:
    let
      entry = registry.entries.${consumer};
      meta = data.consumerMeta.${consumer} or null;
    in
    if entry.capability == "all" then
      "✅"
    else if meta == null then
      "—"
    else if consumer == "zed" then
      "✅ ${meta.name}"
    else if (meta.extensions or [ ]) != [ ] then
      "✅ ${lib.concatMapStringsSep " " (e: "`${e}`") meta.extensions}"
    else
      "✅";

  consumerColumns = lib.attrNames registry.entries;

  languageRow =
    name:
    let
      data = languageData name;
    in
    lib.concatStringsSep " | " (
      [
        "`${name}`"
        (code data.language.lspServers)
        (code (data.language.formatters or [ ]))
      ]
      ++ map (consumer: coverage consumer data) consumerColumns
    );

  addonRow =
    name:
    let
      data = addonData name;
      defined = lib.attrNames (data.lsps or { });
      attached = data.lspServers or defined;
      targets = data.languages or [ "*" ];
    in
    lib.concatStringsSep " | " [
      "`${name}`"
      (code attached)
      (code (lib.subtractLists attached defined))
      (if targets == [ "*" ] then "every enabled language" else code targets)
    ];

  matrix = writeText "support-matrix.md" ''
    # Support matrix

    Generated from the language and addon definitions in `modules/devix`, so it
    cannot drift from the code.

    ## Languages

    A consumer whose `capability` is `"all"` configures every language
    generically. One with `capability = "meta"` only covers languages that carry
    metadata for it — the marks below show the Zed language name and the
    OpenCode file extensions that metadata provides.

    | Language | Language servers | Formatters | ${lib.concatStringsSep " | " consumerColumns} |
    |---|---|---|${lib.concatStringsSep "" (map (_: "---|") consumerColumns)}
    ${lib.concatMapStringsSep "\n" (name: "| ${languageRow name} |") languageNames}

    Consumer capabilities: ${
      lib.concatMapStringsSep ", " (
        consumer: "**${consumer}** `${registry.entries.${consumer}.capability}`"
      ) consumerColumns
    }.

    ## Addons

    | Addon | Attached by default | Available, not attached | Attaches to |
    |---|---|---|---|
    ${lib.concatMapStringsSep "\n" (name: "| ${addonRow name} |") addonNames}

    A server in the *Available, not attached* column is defined in the registry
    but stays inactive until you add it to that addon's `lspServers`.
  '';
in
runCommand "devix-reference" { } ''
  mkdir -p $out
  cp ${matrix} $out/support-matrix.md
  ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: page: "cp ${page} $out/${name}") pages)}
''
