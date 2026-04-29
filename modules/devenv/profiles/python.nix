{ pkgs, ... }:
{
  development.languages.python = {
    enable = true;

    lsps.pyright = {
      package = pkgs.pyright;
      config.python.analysis.typeCheckingMode = "strict";
    };

    formatters = {
      ruff-check = {
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
        command = "ruff";
        args = [
          "format"
          "-"
        ];
      };
    };
  };
}
