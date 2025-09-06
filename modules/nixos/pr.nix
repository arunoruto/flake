{
  config,
  pkgs,
  ...
}:
let
  nixpkgs-tars = "https://github.com/NixOS/nixpkgs/archive/";
in
{
  nixpkgs.config = {
    packageOverrides = pkgs: {
      pr324549 = import (fetchTarball {
        url = "${nixpkgs-tars}fdef90a430d23487ea285197eb37338f6c97cbb1.tar.gz";
        sha256 = "1id3k5shi2ffyqb4ph597bj5ybs1jfjk7sqrpn6ii4svlzlg33n5";
      }) { inherit (config.nixpkgs) config; };
    };
  };

  environment.systemPackages = with pkgs; [
    pr324549.zed-editor
  ];
}
