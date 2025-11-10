{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  cmake,
  python3,

  tree,
}:

stdenv.mkDerivation rec {
  pname = "spirv-tools";
  version = "1.3.296.0";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Reflect";
    rev = "vulkan-sdk-${version}";
    hash = "sha256-Id3XkILhnGvir+KZJhym9iwyJyEOwAkRzpDyc2M4QBM=";
    fetchSubmodules = true;
    # hash = "sha256-Zj9qIvIKyCLgCZVU4X30MiwjkAI8NaIXEsSIPvXiQ3U=";
  };

  # The cmake options are sufficient for turning on static building, but not
  # for disabling shared building, just trim the shared lib from the CMake
  # description
  # patches = lib.optional stdenv.hostPlatform.isStatic ./no-shared-libs.patch;

  nativeBuildInputs = [
    autoPatchelfHook
    cmake
    python3
    tree
  ];

  cmakeFlags = [
    "-DSPIRV_REFLECT_BUILD_TESTS=ON"
    "-DSPIRV_REFLECT_STATIC_LIB=ON"
    "-DSPIRV_REFLECT_EXAMPLES=ON"
    "-DSPIRV_REFLECT_ENABLE_ASAN=ON"
    # "-DSPIRV-Headers_SOURCE_DIR=${spirv-headers.src}"
    # # Avoid blanket -Werror to evade build failures on less
    # # tested compilers.
    # "-DSPIRV_WERROR=OFF"
  ];

  # https://github.com/KhronosGroup/SPIRV-Tools/issues/3905
  # postPatch = ''
  #   substituteInPlace CMakeLists.txt \
  #     --replace '-P ''${CMAKE_CURRENT_SOURCE_DIR}/cmake/write_pkg_config.cmake' \
  #               '-DCMAKE_INSTALL_FULL_LIBDIR=''${CMAKE_INSTALL_FULL_LIBDIR}
  #                -DCMAKE_INSTALL_FULL_INCLUDEDIR=''${CMAKE_INSTALL_FULL_INCLUDEDIR}
  #                -P ''${CMAKE_CURRENT_SOURCE_DIR}/cmake/write_pkg_config.cmake'
  #   substituteInPlace cmake/SPIRV-Tools.pc.in \
  #     --replace '$'{prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@ \
  #     --replace '$'{prefix}/@CMAKE_INSTALL_INCLUDEDIR@ @CMAKE_INSTALL_FULL_INCLUDEDIR@
  #   substituteInPlace cmake/SPIRV-Tools-shared.pc.in \
  #     --replace '$'{prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@ \
  #     --replace '$'{prefix}/@CMAKE_INSTALL_INCLUDEDIR@ @CMAKE_INSTALL_FULL_INCLUDEDIR@
  # '';

  preInstall = ''
    ls -la ./bin
  '';

  postInstall = ''
    # cp -r ./examples $out
    cp ./test-spirv-reflect $out/bin/
    ls -la .
    ls -la ./bin
    ls -la ./lib
    # cp -r . $out
    tree .
  '';

  # doCheck = true;
  checkPhase = ''
    runHook preCheck

    ./test-spirv-reflect

    runHook postCheck
  '';

  meta = with lib; {
    description = "SPIRV-Reflect is a lightweight library that provides a C/C++ reflection API for SPIR-V shader bytecode in Vulkan applications.";
    homepage = "https://github.com/KhronosGroup/SPIRV-Reflect";
    license = licenses.asl20;
    platforms = with platforms; unix ++ windows;
    maintainers = [ maintainers.arunoruto ];
  };
}
