# Pure tag predicate, importable directly so home-manager and darwin modules
# (which don't receive the flake's extended ./lib) can use it too. It is applied
# as `config.lib.tags.hasTag` in the nixos/darwin/home-manager tag modules and
# read uniformly as `config.lib.tags.hasTag "<tag>"`.
#
#   import ./has-tag.nix lib <config|osConfig> "<tag>" -> bool
#
# Null-safe: returns false when there is no tagged system (e.g. standalone
# home-manager where osConfig == null).
lib: cfg: tag:
cfg != null && lib.elem tag (cfg.system.tags or [ ])
