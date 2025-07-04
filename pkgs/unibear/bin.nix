{
  lib,
  stdenvNoCC,
  fetchurl,
# nix-update-script,
# autoPatchelfHook,

# libgcc,
}:
let
  os-arch-options = {
    aarch64-darwin = {
      name = "unibear-darwin_aarch64-apple-darwin";
      hash = "sha256-kYfL+ou4SlZChiaNZOscSzGZSIdiZpJ3QnGBPgtpJ5U=";
    };
    aarch64-linux = {
      name = "unibear-linux_aarch64-unknown-linux-gnu";
      hash = "sha256-BYu4wvv80yThc9O3pUMCAGJQkaVzlVbgIvIXUf6hhro=";
    };
    x86_64-darwin = {
      name = "unibear-darwin_x86_64-apple-darwin";
      hash = "sha256-u7wDsHiFyRyQiIr05hMmtbEABzRuJsLFLPZdY1SKmG4=";
    };
    x86_64-linux = {
      name = "unibear-linux_x86_64-unknown-linux-gnu";
      hash = "sha256-4ahYZvdrRBIeI9+xV6SL+03JQALiq83hGmq5ZEZnIPA=";
    };
  };
  name-hash =
    os-arch-options."${stdenvNoCC.hostPlatform.system}"
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "unibear";
  version = "0.4.2";

  src = fetchurl {
    url = "https://github.com/kamilmac/unibear/releases/download/v${finalAttrs.version}/${name-hash.name}";
    inherit (name-hash) hash;
  };

  dontUnpack = true;

  # nativeBuildInputs = [ autoPatchelfHook ];

  # buildInputs = [ libgcc.lib ];

  # preBuild = ''
  #   addAutoPatchelfSearchPath ${lib.makeLibraryPath finalAttrs.buildInputs}
  # '';

  installPhase = ''
    runHook preInstall

    install "$src" -Dm755 "$out"/bin/${finalAttrs.meta.mainProgram}

    runHook postInstall
  '';

  # preFixup = ''
  #   patchelf \
  #     --set-rpath "${lib.makeLibraryPath finalAttrs.buildInputs}" \
  #     "$out"/bin/${finalAttrs.meta.mainProgram}
  # '';

  # passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lean TUI AI assistant";
    homepage = "https://github.com/kamilmac/unibear";
    license = lib.licenses.mit;
    mainProgram = "unibear";
    platforms = lib.attrsets.mapAttrsToList (name: value: name) os-arch-options;
    maintainers = with lib.maintainers; [ arunoruto ];
  };
})
