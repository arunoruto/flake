{pkgs, ...}: {
  programs.helix = {
    languages = {
      language = [
        {
          name = "python";
          auto-format = true;
          language-servers = [
            "pyright"
            "ruff"
          ];
          formatter = {
            command = "ruff";
            args = ["format" "--line-length" "88" "--quiet" "-"];
          };
          roots = [
            "setup.py"
            "setup.cfg"
            "pyproject.toml"
            "pyrightconfig.json"
            "Poetry.lock"
          ];
        }
      ];
      language-server = {
        pyright.config.python.analysis.typeCheckingMode = "basic";
        ruff = {
          command = "ruff";
          args = ["server" "--preview"];
        };
        # pylsp.config.pylsp = {
        #   plugins.ruff.enabled = true;
        #   plugins.ruff.formatEnabled = true;
        # };
      };
    };
    extraPackages = with pkgs; [
      pyright
      unstable.ruff
    ];
  };
}
