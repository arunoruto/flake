{
  lib,
  intel-llvm,
  fetchFromGitHub,
  cmake,
  onetbb,
  nix-update-script,
}:
intel-llvm.stdenv.mkDerivation (finalAttrs: {
  pname = "onedpl";
  version = "2022.11.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "uxlfoundation";
    repo = "oneDPL";
    tag = "oneDPL-${finalAttrs.version}-release";
    hash = "sha256-NfyV34mdKfCxlU+l6ETKWcC9MwvVEgwcBedtLe6WCV4=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    intel-llvm # Workaround; can be removed once https://github.com/NixOS/nixpkgs/pull/513506 gets merged
    onetbb
  ];

  cmakeFlags = [
    (lib.cmakeFeature "ONEDPL_BACKEND" "dpcpp")
  ];

  doCheck = true;
  checkInputs = [ intel-llvm ];
  checkTarget = "build-onedpl-tests";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex 'oneDPL-(.*)-release'" ];
  };

  meta = {
    description = "oneAPI DPC++ Library (oneDPL)";
    homepage = "http://uxlfoundation.github.io/oneDPL";
    changelog = "https://github.com/uxlfoundation/oneDPL/releases/tag/oneDPL-${finalAttrs.version}-release";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = lib.platforms.all;
  };
})
