# This file defines overlays
{ inputs, ... }:
rec {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: prev: import ../pkgs final.pkgs;

  # Python package addition and override
  python = final: prev: {
    python3 = prev.python3.override {
      packageOverrides = final: prev: import ../pkgs/python.nix final.pkgs;
    };
    pythonPackages = final.python3.pkgs;
  };

  # KODi packages
  kodi = final: prev: {
    kodiPackages = prev.kodiPackages // (import ../pkgs/kodi.nix final);

    # kodi = prev.kodi.override {
    #   withPackages = f: prev.kodi.withPackages (oldPkgs: f final.kodiPackages);
    # };
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    fw-ectool = prev.fw-ectool.overrideAttrs (oldAttrs: {
      cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
      # cmake = final.pkgs.cmake;
      # postPatch = ''
      #   substituteInPlace CMakeLists.txt --replace-fail \
      #     'cmake_minimum_required(VERSION 3.1)' \
      #     'cmake_minimum_required(VERSION 4.0)'
      # '';
    });
  };

  # custom nvim for the future maybe?
  # my-nixvim = final: prev: {
  #   neovim = inputs.nixvim-flake.packages.${final.system}.default;
  # };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      overlays = [
        modifications
        # (final: prev: {
        #   fw-ectool = prev.fw-ectool.overrideAttrs (oldAttrs: {
        #     postPatch = ''
        #       substituteInPlace CMakeLists.txt --replace-fail \
        #         'cmake_minimum_required(VERSION 3.1)' \
        #         'cmake_minimum_required(VERSION 4.0)'
        #     '';
        #   });
        # })
      ];
      config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };
    };
  };
}
