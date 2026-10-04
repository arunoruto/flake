# Steamix VM tests, run with the NixOS test driver:
#
#   nix build .#checks.x86_64-linux.greetd          # from steamix/
#   nix build .#steamix-tests.stable.greetd         # from the parent flake
#   nix build .#steamix-tests.unstable.greetd       # ...against nixpkgs-unstable
#
# Add `.driverInteractive` and run `result/bin/nixos-test-driver` to poke at
# a test VM by hand.
#
# Takes a plain nixpkgs; Steam is replaced by a stub (./lib.nix), so nothing
# here needs allowUnfree.
{ pkgs }:
let
  testLib = import ./lib.nix { inherit pkgs lib; };
  inherit (pkgs) lib;

  runTest = file: pkgs.testers.runNixOSTest (import file { inherit testLib; });
in
{
  greetd = runTest ./greetd.nix;
  decky-loader = runTest ./decky-loader.nix;
}
