# Every `<addon>.nix` next to this file is one addon definition: a group of
# language servers that is not a language of its own (grammar checking, AI
# completion, …), which core/mkAddon.nix turns into a
# `devix.addons.<addon>` option.
#
# Adding an addon is adding a file here — there is no list to keep in sync.
{ lib, ... }:
let
  mkAddon = import ../core/mkAddon.nix;

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
        (mkAddon {
          inherit dataPath;
          name = lib.removeSuffix ".nix" fileName;
        })
      ];
    }
  ) dataFiles;
}
