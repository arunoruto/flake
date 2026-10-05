# Everything `eval-all.sh` hands to nix-eval-jobs: one derivation per
# configuration, named `<output>.<name>` like the lines eval-all prints.
# nix-eval-jobs gives each worker its own process and recycles it once it
# outgrows --max-memory-size; `nix flake check` instead keeps every host's
# evaluation alive in one process (~17 GB heap), which swaps on CI runners.
let
  flake = builtins.getFlake (toString ../.);
  inherit (flake.inputs.nixpkgs) lib;
  toplevels = lib.mapAttrs (_: c: c.config.system.build.toplevel);
in
{
  nixosConfigurations = toplevels flake.nixosConfigurations;
  darwinConfigurations = toplevels flake.darwinConfigurations;
  homeConfigurations = lib.mapAttrs (_: c: c.activationPackage) flake.homeConfigurations;
  devShells.x86_64-linux = flake.devShells.x86_64-linux;
}
