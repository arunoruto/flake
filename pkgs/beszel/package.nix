{
  buildGoModule,
  lib,
  fetchFromGitHub,
  nix-update-script,
  buildNpmPackage,
}:
buildGoModule (finalAttrs: {
  pname = "beszel";
  version = "0.12.6";

  src = fetchFromGitHub {
    owner = "henrygd";
    repo = "beszel";
    hash = "sha256-OZD8nB2oKaMFvUbDfYNhtq18riaQSdTZASDUJ29TYu8=";
    hash = "sha256-6hqRlttuDU5mAqgClc5I+lSx+XHpNPuOLirbVEA08/g=";
  };

  webui = buildNpmPackage {
    inherit (finalAttrs)
      pname
      version
      src
      meta
      ;

    npmFlags = [ "--legacy-peer-deps" ];

    buildPhase = ''
      runHook preBuild

      npx lingui extract --overwrite
      npx lingui compile
      node --max_old_space_size=1024000 ./node_modules/vite/bin/vite.js build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r dist/* $out

      runHook postInstall
    '';

    sourceRoot = "${finalAttrs.src.name}/internal/site";

    npmDepsHash = "sha256-6J1LwRzwbQyXVBHNgG7k8CQ67JZIDqYreDbgfm6B4w4=";
  };

  # sourceRoot = "${src.name}";

  vendorHash = "sha256-NEJ93Q4yzMu9CN9LVK88ytfCwhe8Gz//lPAsx/Y3VRY=";

  postPatch = ''substituteInPlace go.mod --replace "go 1.25.1" "go 1.25.0"'';

  preBuild = ''
    mkdir -p site/dist
    cp -r ${finalAttrs.webui}/* site/dist
  '';

  postInstall = ''
    mv $out/bin/agent $out/bin/beszel-agent
    mv $out/bin/hub $out/bin/beszel-hub
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--subpackage"
      "webui"
    ];
  };

  meta = {
    homepage = "https://github.com/henrygd/beszel";
    changelog = "https://github.com/henrygd/beszel/releases/tag/v${finalAttrs.version}";
    description = "Lightweight server monitoring hub with historical data, docker stats, and alerts";
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    license = lib.licenses.mit;
  };
})
