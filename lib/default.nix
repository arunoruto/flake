lib: rec {
  systemConfig = import ../systems/lib.nix lib;
  arr = import ../modules/nixos/media/arr/lib.nix lib;
  networking = import ../modules/nixos/services/network/lib.nix lib;

  getDirectories =
    path:
    builtins.attrNames (
      lib.attrsets.filterAttrs (_: fileType: fileType == "directory") (builtins.readDir path)
    );
  getDirectoriesAndFilter =
    path: file:
    lib.lists.filter (dirName: builtins.pathExists (path + "/${dirName}" + "/${file}")) (
      getDirectories path
    );
}
