{
  lib,
  stdenv,
  fetchurl,
  callPackage,
}:

let
  pname = "via";
  version = "3.0.0";

  srcs = {
    x86_64-linux = fetchurl {
      url = "https://github.com/the-via/releases/releases/download/v${version}/via-${version}-linux.AppImage";
      sha256 = "sha256-+uTvmrqHK7L5VA/lUHCZZeRYPUrcVA+vjG7venxuHhs=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/the-via/releases/releases/download/v${version}/via-${version}-mac.dmg";
      sha256 = "sha256-MPn4EVSo7pwM8Z9PsaPWyppEj3ZRIoRdseGQufWD0Ws=";
    };
  };

  mkDerivation =
    if stdenv.hostPlatform.isDarwin then callPackage ./darwin.nix { } else callPackage ./linux.nix { };
in
mkDerivation {
  inherit pname version;
  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  # Repo convention for new packages; ./darwin.nix and ./linux.nix forward these
  # on to the derivation they build.
  __structuredAttrs = true;
  strictDeps = true;

  meta = {
    description = "Yet another keyboard configurator";
    homepage = "https://caniusevia.com/";
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [ emilytrau ];
    platforms = builtins.attrNames srcs;
    mainProgram = "via";
  };
}
