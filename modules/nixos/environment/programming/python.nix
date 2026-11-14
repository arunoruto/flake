{
  pkgs,
  lib,
  config,
  ...
}:
let
  packages =
    ps:
    with ps;
    [
      # Jupyter
      jupyter
      ipython
      python-lsp-server
      ipympl
      # computing
      # jax
      # jaxlib
      (if config.hosts.nvidia.enable then numbaWithCuda else numba)
      # numba-scipy
      numpy
      scipy
      pandas
      # plotting
      matplotlib
      # plotly # pillow 13 in 26.05 breaks imageio tests (plotly -> scikit-image -> imageio)
      pyvista
      # streamlit # pins pillow<13; 26.05 ships pillow 13
      # Misc
      # manim
      psutil
      # Optional
      # opencv4
      # pillow
      # requests
      # scikit-image

      # CLI tools
      gruvbox-factory
    ]
    ++ (lib.optionals config.hosts.nvidia.enable [
      jax-cuda12-plugin
    ]);
in
{
  config = lib.mkIf (config.lib.tags.hasTag "development") {
    environment =
      let
        my-python = pkgs.python3.withPackages packages;
      in
      {
        systemPackages =
          (with pkgs; [
            # pillow 13 in 26.05 breaks manim's image tests; re-enable once fixed upstream
            # manim
            # manim-slides
            mkdocs
          ])
          ++ (with pkgs.unstable; [ uv ])
          ++ [ my-python ];

        sessionVariables = {
          PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
        };

        shellAliases = {
          pyrepl = ''
            ${lib.getExe my-python} -i -c "${
              lib.strings.concatStringsSep ";" [
                "import numpy as np"
                "import pandas as pd"
                "import plotly.graph_objects as go"
              ]
            }"
          '';
        };
      };
  };
}
