# Steamix VM tests, run with the NixOS test driver. From steamix/:
#
#   nix build -L .#checks.x86_64-linux.greetd
#
# From the repository root, pinned to the nixpkgs the parent flake locks
# (what CI does; use nixpkgs-unstable for the other channel):
#
#   nix build -L --no-write-lock-file --inputs-from . \
#     --override-input nixpkgs nixpkgs ./steamix#checks.x86_64-linux.greetd
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
  sddm = runTest ./sddm.nix;
  steamos-manager = runTest ./steamos-manager.nix;
  decky-loader = runTest ./decky-loader.nix;
}
