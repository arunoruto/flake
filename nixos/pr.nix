{ config, pkgs, ... }:
let
  nixpkgs-tars = "https://github.com/NixOS/nixpkgs/archive/";
in
{
  nixpkgs.config = {
    packageOverrides = pkgs: {
      #pr284010 = import (fetchTarball
      #  "${nixpkgs-tars}1dc8a2c39ec9e8f3b545c6dbb8fecbb89886d9af.tar.gz")
      #    { config = config.nixpkgs.config; };
    };
  };

  environment.systemPackages = with pkgs; [
    #pr284010.zed-editor
  ];
}
