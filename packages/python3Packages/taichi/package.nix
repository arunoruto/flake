{
  lib,
  stdenv,
  buildPythonPackage,
  fetchurl,
  autoPatchelfHook,
  patchelf,

  # Runtime dependencies
  numpy,
  pybind11,
  tqdm,
  requests,
  mslex,
  psutil,
  colorama,
  dill,
  rich,

  # Libs for patchelf
  zlib,
  libX11,
  libnsl,
  libxcrypt,
  libGL,
  libglvnd,
  vulkan-loader,
}:
let
  finalAttrs = {
    pname = "taichi";
    version = "1.7.4";
  };
in
buildPythonPackage {
  inherit (finalAttrs) pname version;
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/81/cd/3858352ede95ad71a8bec677da440011b42df0214ee675a3dd3f0dea607a/taichi-1.7.4-cp313-cp313-manylinux_2_27_x86_64.whl";
    hash = "sha256-AB/2RyXljiX/gy+sxP8e1d7ZaMZNXNRidXlZmfHM5OA=";
  };

  #   nativeBuildInputs = [
  #     autoPatchelfHook
  #     patchelf
  #   ];

  #   buildInputs = [
  #     stdenv.cc.cc.lib
  #     zlib
  #     libX11
  #     libnsl
  #     libxcrypt
  #     libGL
  #     libglvnd
  #     vulkan-loader
  #   ];

  #   propagatedBuildInputs = [
  #     numpy
  #     pybind11
  #     tqdm
  #     requests
  #     mslex
  #     psutil
  #     colorama
  #     dill
  #     rich
  #   ];

  #   postFixup = ''
  #     for lib in $(find $out -name "*.so"); do
  #       patchelf --add-rpath "${
  #         lib.makeLibraryPath [
  #           libGL
  #           libglvnd
  #           vulkan-loader
  #         ]
  #       }" "$lib"
  #     done
  #   '';

  #   makeWrapperArgs = [
  #     "--prefix LD_LIBRARY_PATH : ${
  #       lib.makeLibraryPath [
  #         libGL
  #         libglvnd
  #         libX11
  #         vulkan-loader
  #       ]
  #     }"
  #   ];

  #   meta = {
  #     description = "Parallel programming for computer graphics";
  #     homepage = "https://taichi-lang.org/";
  #     license = lib.licenses.asl20;
  #     maintainers = with lib.maintainers; [ arunoruto ];
  #     platforms = [ "x86_64-linux" ];
  #   };
}
