{
  pkgs,
  lib,
  config,
  ...
}:
let
  packages =
    ps: with ps; [
      # Jupyter
      jupyter
      ipython
      python-lsp-server
      ipympl
      # Must
      jax
      jaxlib
      matplotlib
      numba
      numba-scipy
      numpy
      pandas
      plotly
      # streamlit
      # Misc
      manim
      psutil
      # Optional
      # opencv4
      # pillow
      # requests
      # scikit-image
    ];
in
{
  options.python.enable = lib.mkEnableOption "Setup a python environment";

  config = lib.mkIf config.python.enable {
    environment = {
      systemPackages = with pkgs; [
        (python3.withPackages packages)
        manim
        manim-slides
        mkdocs
        poetry
      ];

      sessionVariables = {
        PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
      };
    };
  };
}
