{
  lib,
  python3,
  fetchFromGitHub,
  makeWrapper,
}:
let
  python3Packages = python3.pkgs;
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "soulsync";
  version = "2.4.1";
  # pyproject = true;
  # pyproject = false;
  format = "other";

  src = fetchFromGitHub {
    owner = "Nezreka";
    repo = "SoulSync";
    tag = finalAttrs.version;
    hash = "sha256-v1ioMsTIYvMfSaK56p4y/tUMYQ/KV73R/e6yLSAHv0Y=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aiohttp
    beautifulsoup4
    cryptography
    flask
    flask-limiter
    flask-socketio
    gunicorn
    lrclibapi
    mutagen
    pillow
    plexapi
    psutil
    pyacoustid
    requests
    simple-websocket
    spotipy
    tidalapi
    unidecode
    websocket-client
    yt-dlp
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/soulsync

    # 1. Copy all source files into the Nix store
    cp -r . $out/opt/soulsync/

    # 2. Remove the tests folder from the final output
    rm -rf $out/opt/soulsync/tests

    # 3. Pre-compile the Python bytecode
    ${python3.interpreter} -m compileall $out/opt/soulsync

    # 4. Create the executable wrapper
    mkdir -p $out/bin

    # We use explicit --run commands to guarantee bash executes these
    # in the exact order written, utilizing native bash fallback syntax (:-).
    makeWrapper ${python3.pkgs.gunicorn}/bin/gunicorn $out/bin/soulsync \
      --run 'export DATA_DIR="''${SOULSYNC_DATA_DIR:-$HOME/.local/share/soulsync}"' \
      --run 'mkdir -p "$DATA_DIR/database" "$DATA_DIR/logs" "$DATA_DIR/config"' \
      --run 'cd "$DATA_DIR"' \
      --run 'export SOULSYNC_DB_PATH="''${SOULSYNC_DB_PATH:-$DATA_DIR/database/music.db}"' \
      --run 'export SOULSYNC_LOG_DIR="''${SOULSYNC_LOG_DIR:-$DATA_DIR/logs}"' \
      --run 'export SOULSYNC_CONFIG_DIR="''${SOULSYNC_CONFIG_DIR:-$DATA_DIR/config}"' \
      --prefix PYTHONPATH : "$out/opt/soulsync:$PYTHONPATH" \
      --add-flags "-c $out/opt/soulsync/gunicorn.conf.py wsgi:application"

    runHook postInstall
  '';

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  meta = {
    description = "Automated Music Discovery and Collection Manager";
    homepage = "https://ssync.net/";
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
    mainProgram = "soulsync";
    platforms = lib.platforms.linux;
  };
})
