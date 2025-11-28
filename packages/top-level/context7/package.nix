{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,

  nodejs,
  pnpm,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "context7";
  version = "1.0.31";

  src = fetchFromGitHub {
    owner = "upstash";
    repo = "context7";
    tag = "@upstash/context7-mcp@${finalAttrs.version}";
    hash = "sha256-Y0ZjTRc53gcIQDO7UbYcvpXdpeXQdiKFzA8EKQ+uxgA=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
    makeWrapper
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-TbBKl1yB1F0WsmGt5yu/ok40SReDy7hxMg+n8G7rgfc=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Create the root destination and
    # replicate the workspace structure for the specific package
    # We create packages/mcp inside the output so relative links work
    mkdir -p $out/lib/context7/packages/mcp $out/bin

    # Copy the ROOT node_modules (contains the pnpm store and hoisted deps) and remove broken symlinks
    # (The workspace link in root node_modules might still point to /build/source, we clean it up just in case)
    cp -r node_modules $out/lib/context7/node_modules
    find $out/lib/context7/node_modules -xtype l -delete

    # Copy the package-specific node_modules 
    cp -r packages/mcp/node_modules $out/lib/context7/packages/mcp/node_modules

    # Copy the compiled code and package.json
    cp -r packages/mcp/dist $out/lib/context7/packages/mcp/dist
    cp packages/mcp/package.json $out/lib/context7/packages/mcp/package.json

    # Create the wrapper pointing to the deeply nested index.js
    makeWrapper ${nodejs}/bin/node $out/bin/context7-mcp \
      --add-flags "$out/lib/context7/packages/mcp/dist/index.js"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "MCP Server for up-to-date code documentation for LLMs and AI code editors";
    homepage = "https://context7.com/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
    mainProgram = "context7-mcp";
  };
})
