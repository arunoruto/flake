{
  lib,
  stdenv,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,

  bun,
  nodejs_24,
  makeWrapper,
  autoPatchelfHook,
  typescript,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "oh-my-opencode";
  version = "3.15.3";

  src = fetchFromGitHub {
    owner = "code-yeongyu";
    repo = "oh-my-opencode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DNxVT8J6FlzgFfU0OpCXctIDylaiF4CAaKMMVz0ShWo=";
  };

  node-modules = stdenv.mkDerivation {
    pname = "${finalAttrs.pname}-node-modules";
    inherit (finalAttrs) version src;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [ bun ];

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild

      export HOME=$(mktemp -d)
      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

      bun install \
        --no-progress \
        --ignore-scripts
        
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R node_modules $out/

      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-nC7et30a0wmDG6noZNC51pgPlS5rvPyo8w1UMhZ52CQ=";
  };

  nativeBuildInputs = [
    bun
    nodejs_24
    makeWrapper
    typescript
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
    "libc.musl-aarch64.so.1"
  ];

  configurePhase = ''
    runHook preConfigure

    cp -r ${finalAttrs.node-modules}/node_modules .
    chmod -R u+w node_modules
    patchShebangs node_modules/

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    bun run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/oh-my-opencode
    mkdir -p $out/bin

    cp -r dist $out/lib/oh-my-opencode/
    cp -r node_modules $out/lib/oh-my-opencode/
    cp package.json $out/lib/oh-my-opencode/

    makeWrapper ${bun}/bin/bun $out/bin/oh-my-opencode \
      --add-flags "$out/lib/oh-my-opencode/dist/cli/index.js" \
      --prefix PATH : ${
        lib.makeBinPath [
          bun
          nodejs_24
        ]
      }
      
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--subpackage"
      "node-modules"
    ];
  };

  meta = {
    description = "The Best AI Agent Harness - Batteries-Included OpenCode Plugin";
    homepage = "https://github.com/code-yeongyu/oh-my-opencode";
    license = lib.licenses.sustainableUse;
    mainProgram = "oh-my-opencode";
    platforms = with lib.platforms; linux ++ darwin;
  };
})
