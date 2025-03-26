{
  lib,
  stdenvNoCC,
  buildFHSEnv,
  fetchzip,
  nix-update-script,
  versionCheckHook,
}:

let
  arch =
    {
      aarch64-darwin = "arm64";
      aarch64-linux = "arm64";
      x86_64-darwin = "x64";
      x86_64-linux = "x64";
    }
    ."${stdenvNoCC.hostPlatform.system}"
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
  os =
    {
      aarch64-darwin = "darwin";
      aarch64-linux = "linux";
      x86_64-darwin = "darwin";
      x86_64-linux = "linux";
    }
    ."${stdenvNoCC.hostPlatform.system}"
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  executableName = "copilot-language-server";
  fhs =
    { copilot-language-server }:
    buildFHSEnv {
      name = executableName;
      targetPkgs = pkgs: [ pkgs.stdenv.cc.cc.lib ];
      runScript = "${copilot-language-server}/bin/${executableName}";

      meta = copilot-language-server.meta // {
        description =
          copilot-language-server.meta.description
          + " (FHS-wrapped). Use this version if you have trouble with the normal one.";
      };
    };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "copilot-language-server";
  version = "1.290.0";

  src = fetchzip {
    url = "https://github.com/github/copilot-language-server-release/releases/download/${finalAttrs.version}/copilot-language-server-native-${finalAttrs.version}.zip";
    hash = "sha256-ELOSeb3Z7AI8pjDhtUIRoaf+4UXjXKEu/OJ2CLQno6A=";
    stripRoot = false;
  };

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  installPhase = ''
    runHook preInstall

    install -Dt "$out"/bin "${os}-${arch}"/${executableName}

    runHook postInstall
  '';

  dontStrip = true;

  passthru = {
    updateScript = nix-update-script { };
    fhs = fhs { copilot-language-server = finalAttrs.finalPackage; };
  };

  meta = {
    description = "Use GitHub Copilot with any editor or IDE via the Language Server Protocol";
    homepage = "https://github.com/features/copilot";
    license = {
      deprecated = false;
      free = false;
      fullName = "GitHub Copilot Product Specific Terms";
      redistributable = false;
      shortName = "GitHub Copilot License";
      url = "https://github.com/customer-terms/github-copilot-product-specific-terms";
    };
    mainProgram = executableName;
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
