# Python package addition and override
{ ... }:
final: prev: {
  python3 = prev.python3.override {
    packageOverrides = final: prev: import ../packages/python.nix final.pkgs;
  };
  pythonPackages = final.python3.pkgs;

}
