{
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wigxjpf";
  version = "1.13";

  # src = builtins.fetchurl {
  #   url = "http://fy.chalmers.se/subatom/wigxjpf/wigxjpf-${finalAttrs.version}.tar.gz";
  #   sha256 = "0siy9gb7ijg542cvk47298c8cibg9lknwhxvvhgssy2r97yrpawh";
  # };
  src = fetchTarball {
    url = "http://fy.chalmers.se/subatom/wigxjpf/wigxjpf-${finalAttrs.version}.tar.gz";
    sha256 = "0nmcld6iaz4hlgf0dy86jsqw8hchlpys89d132azjsa1gw3ddaav";
  };

  env.NIX_CFLAGS_COMPILE = "-fPIC";

  enableParallelBuilding = true;

  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib,include}

    install -Dm755 bin/wigxjpf $out/bin/
    install -Dm644 lib/*.a $out/lib/
    install -Dm644 inc/*.h $out/include/

    runHook postInstall
  '';

  doCheck = true;
  checkTarget = "test";

  meta = with lib; {
    homepage = "https://fy.chalmers.se/subatom/wigxjpf/";
    changelog = "https://fy.chalmers.se/subatom/wigxjpf/CHANGELOG";
    description = "WIGXJPF evaluates Wigner 3j, 6j and 9j symbols accurately using prime factorisation and multi-word integer arithmetic.";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ arunoruto ];
  };
})
