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
      jax
      jaxlib
      (if config.hosts.nvidia.enable then numbaWithCuda else numba)
      # numba-scipy
      numpy
      pandas
      # plotting
      matplotlib
      plotly
      pyvista
      streamlit
      # Misc
      manim
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
  options.python.enable = lib.mkEnableOption "Setup a python environment";

  config = lib.mkIf config.python.enable {
    environment = {
      systemPackages = with pkgs; [
        (python3.withPackages packages)
        manim
        manim-slides
        mkdocs
        poetry
        uv
      ];

      sessionVariables = {
        PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
      };
    };
  };
}
