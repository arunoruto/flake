{pkgs, ...}: let
  packages = ps:
    with ps; [
      # Jupyter
      jupyter
      ipython
      python-lsp-server
      # Must
      matplotlib
      numba
      numba-scipy
      numpy
      pandas
      plotly
      streamlit
      # Misc
      psutil
      # Optional
      # opencv4
      # pillow
      # requests
      # scikit-image
      # (
      #   buildPythonPackage rec {
      #     pname = "streamlit";
      #     version = "1.21.0";
      #     src = fetchPypi {
      #       inherit pname version;
      #       sha256 = "sha256-xy2WOVCGecXkEdH4htITd3dZUB0Bl1KFwEncMNtGPBo=";
      #     };
      #     doCheck = false;
      #     propagatedBuildInputs = [
      #       # Specify dependencies
      #       #pkgs.python3Packages.numpy
      #       pkgs.python3Packages.python-dateutil
      #       pkgs.python3Packages.click
      #       pkgs.python3Packages.pillow
      #       pkgs.python3Packages.rich
      #       pkgs.python3Packages.pympler
      #       pkgs.python3Packages.protobuf
      #     ];
      #   }
      # )
    ];
in {
  home = {
    packages = with pkgs; [
      (python3.withPackages packages)
      poetry
      mkdocs
      #pkgs.streamlit
    ];

    sessionVariables = {
      # https://github.com/python-poetry/poetry/issues/8623#issuecomment-1793624371
      PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
    };
  };
}
