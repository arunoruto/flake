{
  pkgs,
  lib,
  config,
  ...
}@args:
let
  cfg = config.programs.dev;

  markdownEnabled = cfg.languages.markdown.enable or false;
  typstEnabled = cfg.languages.typst.enable or false;
  latexEnabled = cfg.languages.latex.enable or false;
  nixEnabled = cfg.languages.nix.enable or false;

  hasNixosConfig = args ? osConfig;
  hostName = if hasNixosConfig then args.osConfig.networking.hostName else "";
  flakeLocation = config.home.sessionVariables.NH_FLAKE or null;
in
{
  programs.dev.lsp.servers = {
    ltex = {
      enable = lib.mkOptionDefault false;
      kind = "tool";
      package = pkgs.ltex-ls-plus;
      command = lib.getExe pkgs.ltex-ls-plus;
      settings = {
        ltex = {
          language = "en-GB";
          additionalRules.languageModel = lib.optionalString cfg.lsp.ltex.ngram.enable "${config.home.homeDirectory}/.cache/ngrams";
        };
      };
    };

    harper = {
      enable = lib.mkOptionDefault false;
      kind = "tool";
      package = pkgs.harper;
      command = lib.getExe' pkgs.harper "harper-ls";
      args = [ "--stdio" ];
      settings = {
        harper-ls = {
          diagnosticSeverity = "hint";
          dialect = "American";
        };
      };
    };

    codebook = {
      enable = lib.mkOptionDefault false;
      kind = "tool";
      package = pkgs.unstable.codebook;
      command = lib.getExe' pkgs.unstable.codebook "codebook-lsp";
      args = [ "serve" ];
    };

    marksman = {
      enable = markdownEnabled;
      kind = "tool";
      package = pkgs.marksman;
      command = lib.getExe pkgs.marksman;
    };

    oxide = {
      enable = markdownEnabled;
      kind = "tool";
      package = pkgs.markdown-oxide;
      command = lib.getExe pkgs.markdown-oxide;
    };

    iwe = {
      enable = markdownEnabled;
      kind = "tool";
      package = pkgs.iwe;
      command = lib.getExe' pkgs.iwe "iwes";
    };

    tinymist = {
      enable = typstEnabled;
      package = pkgs.tinymist;
      command = lib.getExe pkgs.tinymist;
    };

    texlab = {
      enable = latexEnabled;
      package = pkgs.texlab;
      command = lib.getExe pkgs.texlab;
    };

    nixd = {
      enable = nixEnabled;
      package = pkgs.unstable.nixd;
      command = lib.getExe pkgs.unstable.nixd;
      settings =
        let
          flake-location = flakeLocation;
        in
        {
          nixpkgs.expr = lib.optionalString (
            flake-location != null
          ) "import (builtins.getFlake ''${flake-location}'').inputs.nixpkgs { }";
          formatting.command = [ "nix fmt" ];
          options = {
            nixos.expr = lib.optionalString (
              flake-location != null && hasNixosConfig
            ) "(builtins.getFlake ''${flake-location}'').nixosConfigurations.${hostName}.options";
            home-manager.expr = lib.optionalString (
              flake-location != null
            ) "(builtins.getFlake ''${flake-location}'').homeConfigurations.${config.user}.options";
          };
          diagnostics = { };
        };
    };

    nil = {
      enable = nixEnabled;
      package = pkgs.nil;
      command = lib.getExe pkgs.nil;
      settings = {
        nil = {
          formatting.command = [ "nix fmt" ];
          diagnostics = {
            ignored = [ ];
            excludeFiles = [ ];
          };
          nix = {
            binary = "nix";
            maxMemoryMB = 2560;
            flake = {
              autoArchive = true;
              autoEvalInputs = false;
              nixpkgsInputName = "nixpkgs";
            };
          };
        };
      };
    };
  };
}
