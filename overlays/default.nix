# This file defines overlays
{ inputs, ... }:
rec {
  # This one brings our custom packages from the 'pkgs' directory
  additions =
    final: prev:
    if prev ? lib then
      prev.lib.packagesFromDirectoryRecursive {
        inherit (final) callPackage;
        inherit (prev) newScope;
        directory = ../packages/top-level;
      }
    else
      { };

  # Python package addition and override
  python = final: prev: {
    pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
      (
        python-final: python-prev:
        if python-prev ? lib then
          python-prev.lib.packagesFromDirectoryRecursive {
            inherit (python-final) callPackage newScope;
            directory = ../packages/python3Packages;
          }
        else
          { }
      )
    ];
  };

  # Kodi packages
  kodi = final: prev: {
    kodiPackages = prev.kodiPackages // {
      elementum = prev.kodiPackages.callPackage ../packages/kodiPackages/elementum/package.nix { };
    };
  };

  # Home Assistant
  home-assistant = final: prev: {
    home-assistant-custom-components =
      (prev.home-assistant-custom-components or { })
      // (
        if prev ? lib then
          prev.lib.packagesFromDirectoryRecursive {
            inherit (final) callPackage;
            inherit (prev) newScope;
            directory = ../packages/home-assistant-custom-components;
          }
        else
          { }
      );
  };

  # steamos-manager, decky-loader and pkgs.deckyPlugins.*, from the in-repo
  # steamos flake — the module's package options default to these.
  steamos = inputs.steamos.overlays.default;

  # Custom packages in versioned namespace
  # These packages are available under pkgs.custom.*
  # Use this for packages where you want control over using custom vs upstream versions
  custom-packages = final: prev: {
    inherit ((import ../packages prev)) custom;
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    fw-ectool = prev.fw-ectool.overrideAttrs (_: {
      cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
    });
    paperlib = prev.paperlib.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.copyDesktopItems ];
      desktopItems = [
        (final.makeDesktopItem {
          name = "paperlib";
          desktopName = "PaperLib";
          exec = "paperlib";
          icon = ./paperlib.png;
          categories = [ "Utility" ];
          terminal = false;
        })
      ];
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      # inherit (final) system;
      inherit (final.stdenv.hostPlatform) system;
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
