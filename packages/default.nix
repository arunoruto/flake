pkgs:
pkgs.lib.makeScope pkgs.newScope (
  self:
  {
    adda-mpi = self.adda.override { target = "mpi"; };
    adda-ocl = self.adda.override { target = "ocl"; };
    copilot-language-server = self.callPackage ./copilot-language-server/package.nix { };
    dpcpp-prop = self.callPackage ./dpcpp/proprietary4.nix { };
    docs = self.callPackage ./docs/package.nix { };
    gemini-cli-custom = self.callPackage ./gemini-cli/package.nix { };
    trmnl = self.callPackage ./trmnl/package.nix { };

    zork2 = self.zork1.override {
      zork = "zork2";
      hash = "sha256-JMEkpwsdUiQgWb0VxTLF4BOptK/gqT/8MdCtwa/2aak=";
    };
    zork3 = self.zork1.override {
      zork = "zork3";
      hash = "sha256-/CqGsDPpCAmC4V3OTWx5vKwln9ap13DLM5I2O+eVwmg=";
    };
  }
  // (pkgs.lib.packagesFromDirectoryRecursive {
    inherit (self) callPackage newScope;
    directory = ./top-level;
  })
  // {
    python3Packages = pkgs.lib.makeScope pkgs.newScope (
      self-p:
      let
        customPackages = pkgs.lib.packagesFromDirectoryRecursive {
          inherit (self-p) callPackage newScope;
          directory = ./python3Packages;
        };
      in
      pkgs.python3Packages // customPackages
    );
  }
  // {
    kodiPackages = pkgs.lib.makeScope pkgs.newScope (
      self-k:
      let
        customKodiPackages = pkgs.lib.packagesFromDirectoryRecursive {
          inherit (self-k) callPackage newScope;
          directory = ./kodiPackages;
        };
      in
      pkgs.kodiPackages // customKodiPackages
    );
  }
  // {
    home-assistant-custom-components = pkgs.lib.makeScope pkgs.newScope (
      self-ha:
      let
        customHaPackages = pkgs.lib.packagesFromDirectoryRecursive {
          inherit (self-ha) callPackage newScope;
          directory = ./home-assistant-custom-components;
        };
      in
      (pkgs.home-assistant-custom-components or { }) // customHaPackages
    );
  }
  // {
    custom = pkgs.lib.makeScope pkgs.newScope (
      self-custom:
      (pkgs.lib.packagesFromDirectoryRecursive {
        inherit (self-custom) callPackage newScope;
        directory = ./custom;
      })
    );
  }
)
