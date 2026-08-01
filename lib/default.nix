lib: rec {
  arr = import ./arr.nix lib;
  networking = import ./networking.nix lib;

  # Tag predicate, pre-bound to the function library:
  #   lib.hasTag config [ "system" "tags" ] "desktop" -> bool
  # NixOS/darwin modules normally use the bound form `config.lib.tags.hasTag`
  # instead (see modules/shared/tags.nix); ./has-tag.nix documents why
  # home-manager imports the file directly.
  hasTag = import ./has-tag.nix lib;

  # Directory names (only) inside `path`.
  getDirectories =
    path:
    builtins.attrNames (
      lib.attrsets.filterAttrs (_: fileType: fileType == "directory") (builtins.readDir path)
    );

  # Evaluate `f` for each system and merge the per-output results into a
  # `{ <output>.<system> = ...; }` shape. Used for devShells/packages/checks.
  eachSystem =
    systems: f:
    builtins.foldl' (
      acc: system:
      let
        ret = f system;
      in
      builtins.foldl' (
        a: key:
        a
        // {
          ${key} = (a.${key} or { }) // {
            ${system} = ret.${key};
          };
        }
      ) acc (builtins.attrNames ret)
    ) { } systems;
}
