lib: rec {
  arr = import ../modules/nixos/services/media/arr/lib.nix lib;
  networking = import ../modules/nixos/services/network/lib.nix lib;

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
