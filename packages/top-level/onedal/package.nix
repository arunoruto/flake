{
  lib,
  intel-llvm,
  fetchFromGitHub,
  nix-update-script,

  onetbb,
  mkl,
  onedpl,
  procps,
  which,
}:
intel-llvm.stdenv.mkDerivation (finalAttrs: {
  pname = "onedal";
  version = "2025.11.0";

  # __structuredAttrs = true;
  # strictDeps = true;

  src = fetchFromGitHub {
    owner = "uxlfoundation";
    repo = "oneDAL";
    tag = finalAttrs.version;
    hash = "sha256-RdHuBQfLdrfLIfoC+EdibX7ie/QAW9h8mbP3fu3Vwhs=";
  };

  env = {
    TBBROOT = "${onetbb}";
    MKLROOT = "${mkl}";
    DPL_ROOT = "${onedpl}";
  };

  nativeBuildInputs = [
    procps
    which
  ];

  buildInputs = [
    # intel-llvm # Workaround; can be removed once https://github.com/NixOS/nixpkgs/pull/513506 gets merged
    onetbb
    mkl
    onedpl
  ];

  makeFlags = [
    "PLAT=lnx32e"
    "COMPILER=clang"
  ];

  buildFlags = [
    "daal"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    # We use a glob here because the output folder name can sometimes append the compiler name
    cp -a __release_lnx*/daal/latest/* $out/

    runHook postInstall
  '';

  # doCheck = true;
  # checkInputs = [ intel-llvm ];
  # checkTarget = "build-onedpl-tests";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "oneAPI Data Analytics Library (oneDAL)";
    homepage = "http://uxlfoundation.github.io/oneDAL";
    changelog = "https://github.com/uxlfoundation/oneDAL/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ arunoruto ];
    platforms = lib.platforms.all;
  };
})
