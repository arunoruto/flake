{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (!config.hosts.tinypc.enable) {
    home.packages = with pkgs.unstable; [ ty ];
    programs.ruff = {
      enable = true;
      package = pkgs.unstable.ruff;
      settings = {
        # Same as Black.
        line-length = 88;
        indent-width = 4;

        lint = {
          # Enable Pyflakes (`F`) and a subset of the pycodestyle (`E`)  codes by default.
          # Unlike Flake8, Ruff doesn't enable pycodestyle warnings (`W`) or
          # McCabe complexity (`C901`) by default.
          select = [
            "E4"
            "E7"
            "E9"
            "F"
            "B"
          ];
          ignore = [ ];

          # Allow fix for all enabled rules (when `--fix`) is provided.
          fixable = [ "ALL" ];
          unfixable = [ ];
        };

        format = {
          # Like Black, use double quotes for strings.
          quote-style = "double";
          # Like Black, indent with spaces, rather than tabs.
          indent-style = "space";
          # Like Black, respect magic trailing commas.
          skip-magic-trailing-comma = false;
          # Like Black, automatically detect the appropriate line ending.
          line-ending = "auto";
        };
      };
    };
  };
}
