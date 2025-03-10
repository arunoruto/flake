lib: {
  listDirs =
    path:
    lib.attrsets.mapAttrsToList (k: v: k) (
      lib.attrsets.filterAttrs (k: v: v == "directory") (builtins.readDir path)
    );
}
