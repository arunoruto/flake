{
  lib,
  stdenv,

  cmake,
  tcsh,
}:
let
  pname = "cspice";
  version = "67";

in
stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = builtins.fetchTarball {
    url = "https://naif.jpl.nasa.gov/pub/naif/toolkit//C/PC_Linux_GCC_64bit/packages/${pname}.tar.Z";
    sha256 = "sha256:03bn5jy0b71h55a96xz0w8gap8xxlpiz17vymxa5k8d6ik36hj57";
  };

  nativeBuildInputs = [
    cmake
    tcsh
  ];

  configurePhase = ":";

  buildPhase = ''
    substituteInPlace \
      src/brief_c/mkprodct.csh \
      src/chrnos_c/mkprodct.csh \
      src/ckbref_c/mkprodct.csh \
      src/commnt_c/mkprodct.csh \
      src/cook_c/mkprodct.csh \
      src/cspice/mkprodct.csh \
      src/csupport/mkprodct.csh \
      src/dskbrief_c/mkprodct.csh \
      src/dskexp_c/mkprodct.csh \
      src/frmdif_c/mkprodct.csh \
      src/inspkt_c/mkprodct.csh \
      src/mkdsk_c/mkprodct.csh \
      src/mkspk_c/mkprodct.csh \
      src/msopck_c/mkprodct.csh \
      src/spacit_c/mkprodct.csh \
      src/spkdif_c/mkprodct.csh \
      src/spkmrg_c/mkprodct.csh \
      src/tobin_c/mkprodct.csh \
      src/toxfr_c/mkprodct.csh \
      src/versn_c/mkprodct.csh \
      --replace-fail "/bin/csh" "${lib.getExe tcsh}"
  '';

  installPhase = ''
    tcsh -f makeall.csh

    mkdir $out
    cp -r . $out

    runHook postInstallPhase
  '';

  postInstallPhase = ''
    ln -s $out/exe $out/bin
    ln -s $out/lib/cspice.a $out/lib/libcspice.a
    ln -s $out/lib/csupport.a $out/lib/libcsupport.a
  '';

  meta = with lib; {
    homepage = "https://naif.jpl.nasa.gov/naif/toolkit.html";
    description = "A comprehensive toolkit and api to design, simulate and analyse space missions";
    license = licenses.free;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
}
