lib: rec {
  systemConfig = import ../systems/lib.nix lib;
  arr = import ../modules/nixos/services/media/arr/lib.nix lib;
  networking = import ../modules/nixos/services/network/lib.nix lib;

  # Whether a system carries a given tag. Pass the module `config`
  # (NixOS/Darwin); null-safe so contexts without a system return false.
  # Note: this extended lib only reaches NixOS modules — home-manager and
  # darwin modules get a plain lib, so they define a small local equivalent.
  hasTag = cfg: tag: cfg != null && lib.elem tag (cfg.system.tags or [ ]);

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
