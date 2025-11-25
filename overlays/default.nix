# This file defines overlays
{ inputs, ... }:
rec {
  # This one brings our custom packages from the 'pkgs' directory
  additions =
    final: prev:
    prev.lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      inherit (prev) newScope;
      directory = ../packages/top-level;
    };

  # Python package addition and override
  python = final: prev: {
    # python3 = prev.python3.override {
    #   packageOverrides = final: prev: import ../packages/python.nix final.pkgs;
    # };
    # pythonPackages = final.python3.pkgs;
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (
        python-final: python-prev:
        python-prev.lib.packagesFromDirectoryRecursive {
          inherit (python-final) callPackage newScope;
          directory = ../packages/python3Packages;
        }
      )
    ];
  };

  # KODi packages
  kodi = final: prev: {
    kodiPackages = prev.kodiPackages // {
      elementum = prev.kodiPackages.callPackage ../packages/kodiPackages/elementum/package.nix { };
    };
    # // prev.lib.packagesFromDirectoryRecursive {
    #   inherit (final.kodiPackages) callPackage;
    #   inherit (prev) newScope;
    #   directory = ../packages/kodiPackages;
    # };

    # kodi = prev.kodi.override {
    #   withPackages = f: prev.kodi.withPackages (oldPkgs: f final.kodiPackages);
    # };
  };

  # Home Assistant
  home-assistant = final: prev: {
    home-assistant-custom-components =
      prev.home-assistant-custom-components
      // prev.lib.packagesFromDirectoryRecursive {
        inherit (final) callPackage;
        inherit (prev) newScope;
        directory = ../packages/home-assistant-custom-components;
      };
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    fw-ectool = prev.fw-ectool.overrideAttrs (_: {
      cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
    });
    gtksourceview5 = prev.gtksourceview5.overrideAttrs (old: {
      doCheck = false;
    });
    # p8-platform = prev.p8-platform.overrideAttrs (oldAttrs: {
    #   cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      overlays = [
        additions
        modifications
        kodi
      ];
      config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };
    };
  };
}
