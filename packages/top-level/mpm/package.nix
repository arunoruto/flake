{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  unzip,
  pam,
  zlib,
  versionCheckHook,
}:

# Mirrors the proposal on NixOS/nixpkgs#558921; drop once mpm lands upstream.
stdenv.mkDerivation (finalAttrs: {
  pname = "mpm";
  version = "2026.7.1";

  src =
    let
      inherit (stdenv.hostPlatform) system;
      source =
        finalAttrs.passthru.supportedPlatforms.${system}
          or (throw "Platform ${system} is not supported by mpm");
    in
    fetchurl {
      url = "https://ssd.mathworks.com/supportfiles/downloads/mpm/${finalAttrs.version}/${source.mathworks_platform}/mpm";
      inherit (source) hash;
    };

  dontUnpack = true;

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    unzip
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    pam
    stdenv.cc.cc.lib # libatomic
    zlib
  ];

  # Not shipped; only wanted by bin/glnxa64/builtinreg, which mpm doesn't run.
  autoPatchelfIgnoreMissingDeps = [ "libmwmw_libtooling.so" ];

  # On Linux the download is a Go launcher that unpacks an embedded ZIP to
  # $TMPDIR and runs the FHS binaries inside. Extract it here instead. Data
  # follows the archive, so cut the file after its end-of-central-directory record.
  installPhase = ''
    runHook preInstall
  ''
  + (
    if stdenv.hostPlatform.isLinux then
      ''
        eocd=$(LC_ALL=C grep -obUaP 'PK\x05\x06' "$src" | tail -n1 | cut -d: -f1)
        head -c $((eocd + 22)) "$src" > payload.zip
        mkdir -p $out/bin $out/libexec
        # exit 1 only warns about the launcher in front of the archive
        unzip -q payload.zip -d $out/libexec/mpm || [ $? -eq 1 ]
        ln -s $out/libexec/mpm/bin/glnxa64/mpm $out/bin/mpm
      ''
    else
      ''
        install -D "$src" $out/bin/mpm
      ''
  )
  + ''
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    supportedPlatforms = {
      "aarch64-darwin" = {
        mathworks_platform = "maca64";
        hash = "sha256-mlokciCZnJbWvQ3VhCJqOSopHEBQ9E/IFaokLKqbNSM=";
      };
      "x86_64-linux" = {
        mathworks_platform = "glnxa64";
        hash = "sha256-dZUwn8LDmp3ZboOMY48EHDPOyxHd/tF7v3EnCfmf0qU=";
      };
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "MATLAB Package Manager";
    homepage = "https://www.mathworks.com/products/mpm.html";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = lib.attrNames finalAttrs.passthru.supportedPlatforms;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "mpm";
  };
})
