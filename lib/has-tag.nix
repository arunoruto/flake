# Pure tag predicate: `hasTag lib root path tag` -> whether `tag` is in the
# string list at `path` within `root` (e.g. root = config, path = [ "system" "tags" ]).
# Null-safe: returns false when `root` is null (e.g. standalone home-manager,
# where osConfig == null). Importable directly so home-manager and darwin modules
# (which don't receive the flake's extended ./lib) can use it too.
#
#   import ./has-tag.nix lib <config|osConfig> [ "system" "tags" ] "<tag>" -> bool
#
# Bind root + path once to get the simpler `tag -> bool` form (see the nixos/
# darwin/home-manager tag modules, which default path to [ "system" "tags" ]).
lib: root: path: tag:
root != null && lib.elem tag (lib.attrByPath path [ ] root)
