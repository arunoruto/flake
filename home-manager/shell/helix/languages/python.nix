{pkgs, ...}: {
  programs.helix = {
    languages = {
      language = [
        {
          name = "python";
          # language-servers = ["pyright" "ruff-lsp"];
          auto-format = true;
          formatter = {
            #command = "black";
            command = "ruff format";
            args = ["--line-length" "88" "--quiet" "-"];
          };
        }
      ];
      language-server = {
        pyright.config.python.analysis.typeCheckingMode = "basic";
        ruff-lsp = {
          command = "ruff-lsp";
          config.settings.args = ["--ignore" "E501"];
        };
        # pylsp.config.pylsp = {
        #   plugins.ruff.enabled = true;
        #   plugins.ruff.formatEnabled = true;
        # };
      };
    };
    extraPackages = with pkgs; [
      pyright
      ruff
      ruff-lsp
      black
      python311Packages.python-lsp-server
      # python311Packages.python-lsp-ruff
    ];
  };
}
