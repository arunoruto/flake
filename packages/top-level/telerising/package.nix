{
  lib,
  stdenv,
  buildFHSEnv,
  fetchzip,
  tzdata,
  zlib,
  expat,
}:
buildFHSEnv rec {
  name = "telerising-api";

  telerising-unpacked = stdenv.mkDerivation (finalAttrs: {
    pname = name;
    version = "0.14.9";

    src = fetchzip {
      url = "https://github.com/sunsettrack4/telerising-api/releases/download/v${finalAttrs.version}/telerising-v${finalAttrs.version}_x86-64_linux.zip";
      hash = "sha256-AdRxJsAy3s6SQGpTLVz9EfY3IflxKhfZ3Hm0nGl4Tno=";
    };

    installPhase = ''
      mkdir -p $out/opt/${finalAttrs.pname}
      mkdir -p $out/bin

      cd telerising
      cp -a ./* $out/opt/${finalAttrs.pname}/

      # Create a smart launcher script
      # Note: The ''$ syntax is Nix's way of escaping the $ sign in multi-line strings
      cat <<EOF > $out/bin/start.sh
      #!/bin/sh

      # 1. Define a writable state directory (defaults to ~/.config/telerising-api)
      STATE_DIR="''${XDG_CONFIG_HOME:-''$HOME/.config}/telerising-api"

      # 2. Create the directory and move into it
      mkdir -p "''$STATE_DIR"
      cd "''$STATE_DIR"

      # 3. Symlink the 'app' directory so Flask can find the HTML templates
      ln -sfn $out/opt/${finalAttrs.pname}/app ./app

      # 4. Execute the application
      exec $out/opt/${finalAttrs.pname}/api "''$@"
      EOF

      chmod +x $out/bin/start.sh
    '';
  });

  targetPkgs = pkgs: [
    zlib
    expat
    tzdata
  ];

  runScript = "${telerising-unpacked}/bin/start.sh";

  meta = with lib; {
    description = "API web application providing Zattoo TV streams";
    homepage = "https://github.com/sunsettrack4/telerising-api";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
