{
  config,
  lib,
  pkgs,
  ...
}: let
  default = {
    nixpkgs.expr = "import <nixpkgs> { }";
    formatting.command = ["nixfmt"];
    options = {
      nixos.expr = "";
      home-manager.expr = "";
    };
    diagnostics.supress = [];
  };
in {
  options = {
    nix-utils.enable = lib.mkEnableOption "Helpful nix utils";
    nixd-config = lib.mkOption {
      type = lib.types.attrs;
      inherit default;
      example = default;
      description = "Configuration of nixd which will be used across multiple IDEs";
    };
  };

  config = lib.mkIf config.nix-utils.enable {
    home.packages = with pkgs; [
      alejandra
      nixd
    ];
  };
}
