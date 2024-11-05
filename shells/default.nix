pkgs: {
  # default = pkgs.callPackage ./csm/package.nix { };
  default = pkgs.mkShell {
    buildInputs = with pkgs; [
      cmake
      glib
      stdenv.cc.cc.lib
      zlib
    ];

    shellHook = ''
      # export LD_LIBRARY_PATH=${
        pkgs.lib.makeLibraryPath [
          pkgs.glib
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
        ]
      }:''$LD_LIBRARY_PATH
      export LD_LIBRARY_PATH=${
        pkgs.lib.makeLibraryPath [
          pkgs.glib
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
        ]
      }
      # https://github.com/python-poetry/poetry/issues/8623#issuecomment-1793624371
      export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
      echo "Flake Env"
    '';
  };
}
