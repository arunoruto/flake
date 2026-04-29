# Language profile definitions for home-manager
{ config, lib, pkgs, ... }:

let
  # Import the same type definitions from devenv
  devenvTypes = import ../../devenv/languages/core.nix { inherit lib; };
  
  # Check if devenv is enabled
  cfg = config.devenv;
in
{
  options.devenv.languages = {
    python = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "Python development environment" // {
            default = false;
          };
          
          configureHelix = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Automatically configure Helix editor for Python.
              Only takes effect if both this language and helix are enabled.
            '';
          };
          
          # Inherit the actual language configuration structure
          # This mirrors the structure in devenv/profiles/python.nix
          lsps = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            visible = false;
            internal = true;
          };
          
          formatters = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            visible = false;
            internal = true;
          };
          
          tabWidth = lib.mkOption {
            type = lib.types.int;
            default = 4;
            visible = false;
            internal = true;
          };
          
          insertSpaces = lib.mkOption {
            type = lib.types.bool;
            default = true;
            visible = false;
            internal = true;
          };
        };
      };
      default = { };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Python language configuration
    (lib.mkIf cfg.languages.python.enable {
      # Define the full Python configuration data
      devenv.languages.python = {
        lsps.pyright = {
          enable = true;
          package = pkgs.pyright;
          command = "pyright-langserver";
          args = [ "--stdio" ];
          config.python.analysis.typeCheckingMode = "strict";
        };

        formatters = {
          ruff-check = {
            enable = true;
            package = pkgs.ruff;
            command = "ruff";
            args = [
              "check"
              "--select"
              "I"
              "--fix"
              "-"
            ];
          };

          ruff-format = {
            enable = true;
            package = pkgs.ruff;
            command = "ruff";
            args = [ "format" "-" ];
          };
        };
      };
      
      # Install packages
      home.packages = [
        pkgs.pyright
        pkgs.ruff
      ];
    })
  ]);
}
