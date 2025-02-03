# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: prev: import ../packages final.pkgs;

  # Python package addition and override
  python = final: prev: {
    python3 = prev.python3.override {
      packageOverrides = final: prev: import ../packages/python.nix final.pkgs;
    };
    pythonPackages = final.python3.pkgs;
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # custom nvim for the future maybe?
  # my-nixvim = final: prev: {
  #   neovim = inputs.nixvim-flake.packages.${final.system}.default;
  # };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };
    };
  };
}
