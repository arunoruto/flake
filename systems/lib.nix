lib:
let
  # Applies a merge operation accross systems.
  eachSystemOp =
    op: systems: f:
    builtins.foldl' (op f) { } (
      if !builtins ? currentSystem || builtins.elem builtins.currentSystem systems then
        systems
      else
        # Add the current system if the --impure flag is used.
        systems ++ [ builtins.currentSystem ]
    );
in
{
  listDirs =
    path:
    lib.attrsets.mapAttrsToList (k: v: k) (
      lib.attrsets.filterAttrs (k: v: v == "directory") (builtins.readDir path)
    );
  eachSystem = eachSystemOp (
    # Merge outputs for each system.
    f: attrs: system:
    let
      ret = f system;
    in
    builtins.foldl' (
      attrs: key:
      attrs
      // {
        ${key} = (attrs.${key} or { }) // {
          ${system} = ret.${key};
        };
      }
    ) attrs (builtins.attrNames ret)
  );

}
