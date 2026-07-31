{
  inputs,
  self,
  lib,
  pkgs-attrs,

  scheme,
  image,
}:
let
  isDarwin = lib.hasInfix "darwin";

  # Architecture directories under systems/ (aarch64-darwin, x86_64-linux, ...).
  # `iso` is not an architecture; it holds the installer image definitions.
  archs = lib.lists.remove "iso" (lib.getDirectories ./.);

  # pkgs is instantiated here rather than by the nixpkgs module, so a host
  # cannot set `nixpkgs.config` from its configuration.nix (the module asserts
  # against it). A host that needs its own nixpkgs `config` — permitted
  # insecure packages, cudaSupport, … — drops a `nixpkgs.nix` next to its
  # configuration.nix; its attributes are merged over the shared config.
  mkPkgs =
    arch: hostname:
    let
      hostConfigPath = ./${arch}/${hostname}/nixpkgs.nix;
      hostConfig = lib.optionalAttrs (lib.pathExists hostConfigPath) (import hostConfigPath);
    in
    import inputs.nixpkgs {
      system = arch;
      inherit (pkgs-attrs) overlays;
      config = pkgs-attrs.config // hostConfig;
    };

  # Module list for a NixOS host.
  nixosModules =
    arch: hostname:
    [
      self.nixosModules.default
      {
        networking.hostName = lib.mkForce hostname;
        facter.reportPath = lib.mkIf (lib.pathExists ./${arch}/${hostname}/facter.json) ./${arch}/${hostname}/facter.json;
        theming = {
          inherit scheme image;
        };
      }
      ./${arch}/${hostname}
      ../homes/nixos.nix
    ]
    ++ (with inputs; [
      nixos-facter-modules.nixosModules.facter
      home-manager.nixosModules.home-manager
      determinate.nixosModules.default
    ]);

  # Module list for a nix-darwin host. Stylix is configured directly by the
  # host (there is no `theming` option on Darwin); scheme/image are unused here.
  darwinModules =
    arch: hostname:
    [
      self.darwinModules.default
      { stylix.enable = true; }
      {
        networking.hostName = hostname;
        home-manager.sharedModules = [
          (
            { osConfig, ... }:
            {
              # Inherit stylix config from the system (Darwin) level
              stylix = {
                inherit (osConfig.stylix) image base16Scheme polarity;
              };
            }
          )
          inputs.mac-app-util.homeManagerModules.default
        ];
      }
      ./${arch}/${hostname}
      ../homes/nixos.nix
    ]
    ++ (with inputs; [
      stylix.darwinModules.stylix
      home-manager.darwinModules.home-manager
      sops-nix.darwinModules.sops
      determinate.darwinModules.default
      mac-app-util.darwinModules.default
    ]);

  mkHost =
    arch: hostname:
    let
      darwin = isDarwin arch;
      builder = if darwin then inputs.nix-darwin.lib.darwinSystem else lib.nixosSystem;
      modules = (if darwin then darwinModules else nixosModules) arch hostname;
    in
    builder {
      pkgs = mkPkgs arch hostname;
      system = arch;
      specialArgs = { inherit inputs self; };
      inherit modules;
    };

  # Build every host under the architectures matching `pred`.
  hostsWhere =
    pred:
    lib.attrsets.mergeAttrsList (
      map (arch: lib.genAttrs (lib.getDirectories ./${arch}) (mkHost arch)) (lib.filter pred archs)
    );

  iso = import ./iso { inherit inputs self lib; };
in
{
  nixos = hostsWhere (arch: !isDarwin arch);
  darwin = hostsWhere isDarwin;
  inherit (iso) isoConfigurations;
}
