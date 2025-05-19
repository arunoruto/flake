{
  lib,
  stdenv,
  stdenvNoCC,
  buildFHSEnv,
  fetchzip,
  nix-update-script,

  testers,
}:

let
  env = stdenv;
  # env = stdenvNoCC;
  arch =
    {
      aarch64-darwin = "arm64";
      aarch64-linux = "arm64";
      arm64-apple-darwin = "arm64";
      x86_64-darwin = "x64";
      x86_64-linux = "x64";
    }
    ."${env.hostPlatform.system}" or (throw "Unsupported system: ${env.hostPlatform.system}");
  os =
    {
      aarch64-darwin = "darwin";
      aarch64-linux = "linux";
      arm64-apple-darwin = "darwin";
      x86_64-darwin = "darwin";
      x86_64-linux = "linux";
    }
    ."${env.hostPlatform.system}" or (throw "Unsupported system: ${env.hostPlatform.system}");

  executableName = "copilot-language-server";
  fhs =
    { package }:
    buildFHSEnv {
      name = package.meta.mainProgram;
      version = package.version;
      targetPkgs = pkgs: [ pkgs.stdenv.cc.cc.lib ];
      runScript = lib.getExe package;

      meta = package.meta // {
        description =
          package.meta.description
          + " (FHS-wrapped). Use this version if you have trouble with the normal one.";
      };
    };
in
env.mkDerivation (finalAttrs: {
  pname = "copilot-language-server";
  version = "1.322.0";

  src = fetchzip {
    url = "https://github.com/github/copilot-language-server-release/releases/download/${finalAttrs.version}/copilot-language-server-native-${finalAttrs.version}.zip";
    hash = "sha256-3AJTC4TI+sqTi1/B1XQZght7CClplWwIxjGmrt1E2ME=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install "${os}-${arch}/${executableName}" -Dm755 -t "$out"/bin

    runHook postInstall
  '';

  dontStrip = true;

  passthru = {
    updateScript = nix-update-script { };
    fhs = fhs { package = finalAttrs.finalPackage; };
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
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
      "arm64-apple-darwin"
    ];
    maintainers = with lib.maintainers; [
      arunoruto
      wattmto
    ];
  };
})
