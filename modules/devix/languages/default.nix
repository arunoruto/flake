# Every `<lang>.nix` next to this file is one language definition: pure data
# (LSPs, formatters, indentation, per-consumer metadata) that
# core/mkLanguage.nix turns into a `devix.languages.<lang>` option.
#
# Adding a language is adding a file here — there is no list to keep in sync.
# Enabling one is policy and belongs to the consumer of this module, not here.
{ lib, ... }:
let
  mkLanguage = import ../core/mkLanguage.nix;

  dataFiles = lib.filterAttrs (
    fileName: type: type == "regular" && fileName != "default.nix" && lib.hasSuffix ".nix" fileName
  ) (builtins.readDir ./.);
in
{
  imports = lib.mapAttrsToList (
    fileName: _:
    let
      dataPath = ./. + "/${fileName}";
    in
    {
      # Point module errors at the data file rather than at "anonymous module".
      _file = toString dataPath;
      imports = [
        (mkLanguage {
          inherit dataPath;
          name = lib.removeSuffix ".nix" fileName;
        })
      ];
    }
  ) dataFiles;
}
