# Python development shell using devenv
{ pkgs, inputs, self, ... }:

let
  devenvConfigs = import ./devenv-shells.nix { inherit self; };
in
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = devenvConfigs.python;
}
