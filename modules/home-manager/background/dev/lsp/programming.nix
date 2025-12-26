{ pkgs, lib, config, ... }:
let
  cfg = config.programs.dev;

  pythonEnabled = cfg.languages.python.enable or false;
  goEnabled = cfg.languages.go.enable or false;
  fishEnabled = cfg.languages.fish.enable or false;
  juliaEnabled = cfg.languages.julia.enable or false;
  matlabEnabled = cfg.languages.matlab.enable or false;
in
{
  programs.dev.lsp.servers = {
    pyright = {
      enable = pythonEnabled;
      tags = [ "python" ];
      package = pkgs.pyright;
      command = lib.getExe' pkgs.pyright "pyright-langserver";
      args = [ "--stdio" ];
      settings = {
        python.analysis.typeCheckingMode = "basic";
      };
    };

    ruff = {
      enable = pythonEnabled && config.programs.ruff.enable;
      tags = [ "python" ];
      package = if config.programs.ruff.enable then config.programs.ruff.package else null;
      command = lib.getExe config.programs.ruff.package;
      args = [ "server" ];
    };

    ty = {
      enable = pythonEnabled && config.programs.ty.enable;
      tags = [ "python" ];
      package = if config.programs.ty.enable then config.programs.ty.package else null;
      command = lib.getExe config.programs.ty.package;
      args = [ "server" ];
    };

    sourcery = {
      enable = lib.mkOptionDefault false;
      tags = [ "python" ];
      package = pkgs.unstable.sourcery;
      command = lib.getExe pkgs.unstable.sourcery;
      args = [ "lsp" ];
    };

    gopls = {
      enable = goEnabled;
      package = pkgs.gopls;
      command = lib.getExe pkgs.gopls;
    };

    golangci-lint-langserver = {
      enable = goEnabled;
      package = pkgs.golangci-lint-langserver;
      command = lib.getExe pkgs.golangci-lint-langserver;
    };

    fish-lsp = {
      enable = fishEnabled;
      package = pkgs.fish-lsp;
      command = lib.getExe pkgs.fish-lsp;
      args = [ "start" ];
    };

    julia-lsp = {
      enable = juliaEnabled;
      package = pkgs.julia;
      command = lib.getExe pkgs.julia;
      args = [
        "--startup-file=no"
        "--history-file=no"
        "--thread=auto"
        "-e"
        "using LanguageServer; runserver();"
      ];
    };

    matlab-ls = {
      enable = matlabEnabled;
      package = pkgs.matlab-language-server;
      command = lib.getExe pkgs.matlab-language-server;
      args = [ "--stdio" ];
      settings = {
        MATLAB = {
          installPath = "/usr/local/MATLAB/R2022a";
          indexWorkspace = "true";
          matlabConnectionTiming = "onStart";
          telemetry = "false";
        };
      };
    };
  };
}
