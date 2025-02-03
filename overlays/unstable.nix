# When applied, the unstable nixpkgs set (declared in the flake inputs) will
# be accessible through 'pkgs.unstable'
{ channels, ... }:
final: prev: {
  unstable = import channels.nixpkgs-unstable {
    system = final.system;
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
    };
  };
}
