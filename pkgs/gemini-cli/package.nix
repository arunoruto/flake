# {
#   lib,
#   buildNpmPackage,
#   fetchFromGitHub,
#   fetchNpmDeps,
#   writeShellApplication,
#   cacert,
#   curl,
#   gnused,
#   jq,
#   nix-prefetch-github,
#   prefetch-npm-deps,
#   gitUpdater,
# }:

# buildNpmPackage (finalAttrs: {
#   pname = "gemini-cli";
#   version = "0.1.13-unstable-2025-07-23";
#   # version = "0.1.7";
#   # version = "0.1.13";

#   src = fetchFromGitHub {
#     owner = "google-gemini";
#     repo = "gemini-cli";
#     rev = "30c68922a372755a5b9f918baf053e0d1f156fc5";
#     # tag = "v${finalAttrs.version}";
#     # hash = "sha256-DAenod/w9BydYdYsOnuLj7kCQRcTnZ81tf4MhLUug6c="; # 0.1.7
#     # hash = "sha256-egQlKqS5pD1mIZChmT2LLnrDq8U+5RbvLNDNhkd5vhE="; # 0.1.13
#     hash = "sha256-BDiphD5YnMU1smApIqbG2l4bF02a3H6+ZFJ3j9/q0eo=";
#   };

#   npmDeps = fetchNpmDeps {
#     inherit (finalAttrs) src;
#     # hash = "sha256-otogkSsKJ5j1BY00y4SRhL9pm7CK9nmzVisvGCDIMlU="; # 0.1.7
#     # hash = "sha256-tzVmMiHP24qKDJZYHLmGZpFZ2Y4uExassO3v3syrl2s="; # 0.1.13
#     hash = "sha256-D0aj/6wREF9g1SZo6rvaCu3wAYl22uWSImO2PDJJvJY=";
#   };

#   preConfigure = ''
#     mkdir -p packages/generated
#     echo "export const GIT_COMMIT_INFO = { commitHash: '${finalAttrs.src.rev}' };" > packages/generated/git-commit.ts
#   '';

#   installPhase = ''
#     runHook preInstall
#     mkdir -p $out/{bin,share/gemini-cli}

#     cp -r node_modules $out/share/gemini-cli/

#     rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli
#     rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-core
#     cp -r packages/cli $out/share/gemini-cli/node_modules/@google/gemini-cli
#     cp -r packages/core $out/share/gemini-cli/node_modules/@google/gemini-cli-core

#     ln -s $out/share/gemini-cli/node_modules/@google/gemini-cli/dist/index.js $out/bin/gemini
#     runHook postInstall
#   '';

#   postInstall = ''
#     chmod +x "$out/bin/gemini"
#   '';

#   passthru.updateScript = gitUpdater { };

#   meta = {
#     description = "AI agent that brings the power of Gemini directly into your terminal";
#     homepage = "https://github.com/google-gemini/gemini-cli";
#     license = lib.licenses.asl20;
#     maintainers = with lib.maintainers; [ donteatoreo ];
#     platforms = lib.platforms.all;
#     mainProgram = "gemini";
#   };
# })

{
  lib,
  git,
  nodejs,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  ...
}:
buildNpmPackage (finalAttrs: {
  pname = "gemini-cli";
  version = "0.1.13-fixed";

  src = fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "5f8fff4db3b88705a261a43f31efe93d2226c07c";
    hash = "sha256-iyIrfsyhCii9Y5IEwj+xmgvqyFjlhDWG2tN6Q1tX/lY=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-Zm3PtIiLNEHqP09YR9+OBp2NdrtU8FxIteEh46zTVuE=";
  };

  passthru.autoUpdate = false;

  patches = [ ./gemini.path ];

  postPatch = ''
    mkdir -p packages/cli/src/generated
    echo "export const GIT_COMMIT_INFO = '${finalAttrs.src.rev}';" > packages/cli/src/generated/git-commit.js
    echo "export const GIT_COMMIT_INFO: string;" > packages/cli/src/generated/git-commit.d.ts
  '';

  nativeBuildInputs = [
    nodejs
    git
  ];

  dontNpmBuild = true;

  buildPhase = ''
    npm run build
  '';

  postInstall = ''
    rm -f $out/share/gemini-cli/node_modules/gemini-cli-vscode-ide-companion
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share/gemini-cli}
    cp -r node_modules $out/share/gemini-cli/
    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli
    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-core
    cp -r packages/cli $out/share/gemini-cli/node_modules/@google/gemini-cli
    cp -r packages/core $out/share/gemini-cli/node_modules/@google/gemini-cli-core
    mkdir -p $out/share/gemini-cli/node_modules/@google/gemini-cli/dist/src/generated
    cp packages/cli/src/generated/git-commit.js $out/share/gemini-cli/node_modules/@google/gemini-cli/dist/src/generated/
    cp packages/cli/src/generated/git-commit.d.ts $out/share/gemini-cli/node_modules/@google/gemini-cli/dist/src/generated/
    ln -s $out/share/gemini-cli/node_modules/@google/gemini-cli/dist/index.js $out/bin/gemini
    chmod +x $out/bin/gemini
    runHook postInstall
  '';

  meta = {
    description = "AI agent that brings the power of Gemini directly into your terminal";
    homepage = "https://github.com/google-gemini/gemini-cli";
    mainProgram = "gemini";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    binaryNativeCode = true;
  };
})
