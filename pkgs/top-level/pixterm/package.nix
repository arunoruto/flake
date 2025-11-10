{
  buildGoModule,
  lib,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "pixterm";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "eliukblau";
    repo = "pixterm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T795x4J1/NZLKgJLdAui/dOZbjpDdpeEK9izQS2/oCM=";
  };

  # sourceRoot = "${finalAttrs.src.name}";

  vendorHash = "sha256-YyhCWt2RqPtHD6Yc/i6Wadcni8kQjPVUnG9U08NoFU8=";

  # postPatch = ''substituteInPlace go.mod --replace "go 1.25.1" "go 1.25.0"'';

  # preBuild = ''
  #   mkdir -p internal/site/dist
  #   cp -r ${finalAttrs.webui}/* internal/site/dist
  # '';

  # postInstall = ''
  #   mv $out/bin/agent $out/bin/beszel-agent
  #   mv $out/bin/hub $out/bin/beszel-hub
  # '';

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/eliukblau/pixterm";
    changelog = "${finalAttrs.meta.homepage}/releases/tag/v${finalAttrs.version}";
    description = "Draw images in your ANSI terminal with true color";
    maintainers = with lib.maintainers; [ arunoruto ];
    license = lib.licenses.mpl20;
  };
})
