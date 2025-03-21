{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  nix-update-script,
# nodejs,
}:

let
  arch =
    {
      aarch64-darwin = "arm64";
      aarch64-linux = "arm64";
      x86_64-darwin = "x64";
      x86_64-linux = "x64";
    }
    ."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  os =
    {
      aarch64-darwin = "darwin";
      aarch64-linux = "linux";
      x86_64-darwin = "darwin";
      x86_64-linux = "linux";
    }
    ."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation (finalAttrs: {
  pname = "copilot-language-server";
  version = "1.280.0";
  # version = "1.286.0";
  # version = "1.290.0";

  src = fetchzip {
    url = "https://github.com/github/copilot-language-server-release/releases/download/${finalAttrs.version}/copilot-language-server-native-${finalAttrs.version}.zip";
    hash = "sha256-s47WaWH0ov/UazQCOFBUAO6ZYgCmCpQ1o79KjAVJFh4=";
    # hash = "sha256-yYsfp3Hdph8zOTkycjjV8nnWe0bT1QYgVSzSHVJ6HzM=";
    # hash = "sha256-ELOSeb3Z7AI8pjDhtUIRoaf+4UXjXKEu/OJ2CLQno6A=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    # nodejs
  ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec
    cp -r ${os}-${arch} $out/libexec/copilot-language-server

    mkdir -p $out/bin
    ln -s $out/libexec/copilot-language-server/copilot-language-server $out/bin/copilot-language-server

    runHook postInstall
  '';

  # installPhase = ''
  #   runHook preInstall

  #   install -Dt "$out"/bin "${os}-${arch}"/copilot-language-server

  #   runHook postInstall
  # '';

  dontStrip = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Use GitHub Copilot with any editor or IDE via the Language Server Protocol";
    homepage = "https://github.com/features/copilot";
    # license = {
    #   deprecated = false;
    #   free = false;
    #   fullName = "GitHub Copilot Product Specific Terms";
    #   redistributable = false;
    #   shortName = "GitHub Copilot License";
    #   url = "https://github.com/customer-terms/github-copilot-product-specific-terms";
    # };
    mainProgram = "copilot-language-server";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = with lib.maintainers; [
      arunoruto
      wattmto
    ];
  };
})
