{ pkgs, ... }:
let
  packages =
    ps: with ps; [
      image
      symbolic
    ];
in
{
  home.packages = with pkgs; [
    octave
    #(octave.withPackages packages)
  ];
}
