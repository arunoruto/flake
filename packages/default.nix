# TODO: create an apple-fonts package inspired by this flake: https://github.com/Lyndeno/apple-fonts.nix
# {
#   pkgs ? import <nixpkgs> {
#     config = {
#       allowUnfree = true;
#     };
#   },
# }:
pkgs:
pkgs.lib.makeScope pkgs.newScope (
  self:
  {
    adda-mpi = self.adda.override { target = "mpi"; };
    adda-ocl = self.adda.override { target = "ocl"; };
    # adda-gui-update-script = adda-gui.mitmCache.updateScript;
    copilot-language-server = pkgs.callPackage ./copilot-language-server/package.nix { };
    # spirv-reflect = pkgs.callPackage ./spirv-reflect { };
    # dpcpp = pkgs.callPackage ./dpcpp { };
    # dpcpp-bin = pkgs.callPackage ./dpcpp/bin.nix { };
    dpcpp-prop = pkgs.callPackage ./dpcpp/proprietary4.nix { };
    gemini-cli-custom = pkgs.callPackage ./gemini-cli/package.nix { };
    # fileflows = pkgs.callPackage ./fileflows/package.nix { };
    # banana-cursor = pkgs.callPackage ./banana-cursor/package.nix {};
    # zluda-rocm5 = pkgs.callPackage ./zluda-rocm5/package.nix { };
    # candy-icons = pkgs.callPackage ./candy-icons/package.nix { };
    # mesa-amber = pkgs.mesa.overrideAttrs (old: {
    #   version = "0-unstable-2024-04-23";
    #   src = pkgs.fetchFromGitLab {
    #     domain = "gitlab.freedesktop.org";
    #     owner = "mesa";
    #     repo = "mesa";
    #     rev = "027ccc89b2ab83fdb9dbc42c9f5a31c175c7f554";
    #     hash = "sha256-r4+lWRS8tBDbIOoQhiu0WcSr8upQruzMRFLHRx9WxGM=";
    #   };
    #   # patches = old.patches or [ ] ++ [ ./mesa-amber.patch ];
    # });
    # tdarr = pkgs.callPackage ./tdarr/package.nix { };
    # tdarr-node = pkgs.callPackage ./tdarr/node.nix { };
    # tdarr-server = pkgs.callPackage ./tdarr/server.nix { };
    # terminus = pkgs.callPackage ./terminus/package.nix { };
    trmnl = pkgs.callPackage ./trmnl/package.nix { };
    # unibear = pkgs.callPackage ./unibear/package.nix { };
    # wigxjpf = pkgs.callPackage ./wigxjpf/package.nix { };
    # taichi = pkgs.python3Packages.callPackage ./taichi { };
    # numba-cuda = pkgs.python3Packages.callPackage ./numba-cuda { };

    # Work testing
    # isis = pkgs.callPackage ./isis/package.nix {
    #   inherit inja;
    #   inherit ale;
    #   inherit cspice;
    #   inherit csm;
    # };
    # inja = pkgs.callPackage ./isis/inja.nix { };
    # ale = pkgs.callPackage ./ale/package.nix { };
    # cspice = pkgs.callPackage ./cspice/package.nix { };
    # csm = pkgs.callPackage ./csm/package.nix { };

    # python3 = pkgs.python3.override {
    #   packageOverrides = final: prev: import ./python.nix pkgs;
    # };

    # kodiPackages = pkgs.kodiPackages.overrideDerivation (prev: import ./kodi.nix pkgs);
    # kodiPackages = pkgs.kodiPackages // (import ./kodi.nix pkgs);
    # kodiPackages = pkgs.kodiPackages;
    # customKodiPackages = import ./kodi.nix pkgs;
  }
  // (pkgs.lib.packagesFromDirectoryRecursive {
    inherit (self) callPackage newScope;
    directory = ./top-level;
  })
  // {
    python3Packages = pkgs.lib.makeScope pkgs.newScope (
      self-k:
      (pkgs.lib.packagesFromDirectoryRecursive {
        inherit (pkgs.python3Packages) callPackage;
        directory = ./python3Packages;
      })
    );
  }
  // {
    kodiPackages = pkgs.lib.makeScope pkgs.newScope (
      self-k:
      (pkgs.lib.packagesFromDirectoryRecursive {
        inherit (pkgs.kodiPackages) callPackage;
        directory = ./kodiPackages;
      })
    );
  }
  // {
    home-assistant-custom-components = pkgs.lib.makeScope pkgs.newScope (
      self-k:
      (pkgs.lib.packagesFromDirectoryRecursive {
        inherit (pkgs) callPackage;
        directory = ./home-assistant-custom-components;
      })
    );
  }
)
