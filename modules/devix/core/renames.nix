# Backwards compatibility: devix options used to live under `development.*`,
# and the master consumer toggle was called `autoConfigureEditors`.
#
# These aliases keep older configurations (including out-of-tree ones importing
# `homeModules.devix` or `devenvModules.*`) working, with a warning pointing at
# the new name. Delete this module once nothing refers to the old paths.
#
# The per-language and per-addon renames are generated from the same directories
# the option modules are generated from, so they stay in step automatically.
{ lib, ... }:
let
  names =
    dir:
    map (lib.removeSuffix ".nix") (
      lib.attrNames (
        lib.filterAttrs (
          fileName: type: type == "regular" && fileName != "default.nix" && lib.hasSuffix ".nix" fileName
        ) (builtins.readDir dir)
      )
    );

  rename = from: to: lib.mkRenamedOptionModule ([ "development" ] ++ from) ([ "devix" ] ++ to);
  keep = path: rename [ path ] [ path ];
in
{
  imports = [
    (rename [ "autoConfigureEditors" ] [ "autoEnable" ])
  ]
  ++ map keep [
    "enable"
    "defaultEditor"
    "consumers"
    "lsps"
    "formatters"
  ]
  ++ map (name: rename [ "languages" name ] [ "languages" name ]) (names ../languages)
  ++ map (name: rename [ "addons" name ] [ "addons" name ]) (names ../addons);
}
