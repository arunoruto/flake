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
      // {
        fetchMatlab = final.callPackage ../packages/top-level/matlab/fetcher.nix { };
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
  # Steamix flake — the module's package options default to these.
  steamix = inputs.steamix.overlays.default;

  # Custom packages in versioned namespace
  # These packages are available under pkgs.custom.*
  # Use this for packages where you want control over using custom vs upstream versions
  # Built against unstable, not the host's nixpkgs: custom/ tracks versions
  # ahead of nixpkgs, and this keeps pkgs.custom.<pkg> on hosts the same store
  # path as `nix build .#custom.<pkg>` (legacyPackages), which is what
  # cachix-sync pushes.
  custom-packages = final: prev: {
    inherit ((import ../packages final.unstable)) custom;
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
