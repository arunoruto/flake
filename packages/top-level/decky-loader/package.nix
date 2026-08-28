{
  lib,
  python3,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_11,
  nodejs,
  coreutils,
  psmisc,
  nix-update-script,
}:

python3.pkgs.buildPythonPackage (finalAttrs: {
  pname = "decky-loader";
  version = "3.2.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "SteamDeckHomebrew";
    repo = "decky-loader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-p1bkLsZedTZ29POqdaXvVpPXzg9kBTKgUxkkEAyAkT0=";
  };

  # The workspace file makes pnpm treat frontend/ as a monorepo root, which
  # the nixpkgs pnpm hooks do not expect. Dropped in both the source tree and
  # the dependency fetch so the two agree on the lockfile.
  postPatch = ''
    rm frontend/pnpm-workspace.yaml
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    pnpm = pnpm_11;
    sourceRoot = "${finalAttrs.src.name}/frontend";
    postPatch = ''
      rm pnpm-workspace.yaml
    '';
    hash = "sha256-OHimg85kcjk+Tq1Yv8TA9CfPDVzxdgPpzTi2mxyPs4s=";
  };

  pnpmRoot = "frontend";

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    pnpm_11
    pnpmConfigHook
  ];

  build-system = with python3.pkgs; [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = with python3.pkgs; [
    aiohttp
    aiohttp-cors
    aiohttp-jinja2
    certifi
    multidict
    packaging
    setproctitle
    watchdog
  ];

  # The Python package is backend/, but the frontend bundle it serves has to
  # be built first and is picked up from the tree next to it.
  preBuild = ''
    cd frontend
    pnpm build
    cd ../backend
  '';

  # Upstream pins these to the versions SteamOS ships.
  pythonRelaxDeps = [
    "aiohttp-cors"
    "packaging"
    "watchdog"
  ];

  # The loader shells out to both while installing and reloading plugins.
  # One list element per argv entry: under __structuredAttrs makeWrapper's
  # arguments are passed through verbatim rather than word-split.
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      coreutils
      psmisc
    ])
  ];

  # Consumers extend the loader's PYTHONPATH for plugins that need extra
  # Python modules; they need the interpreter this was built against.
  passthru = {
    python = python3;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Plugin loader for the Steam Deck";
    homepage = "https://github.com/SteamDeckHomebrew/decky-loader";
    license = lib.licenses.gpl2Only;
    mainProgram = "decky-loader";
    platforms = lib.platforms.linux;
  };
})
