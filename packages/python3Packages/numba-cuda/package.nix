{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,
  setuptools,
  wheel,
  numpy,
  numba,
  packaging,
  cuda-bindings,
  cuda-core,
  cuda-pathfinder,
  cudaPackages,
  symlinkJoin,

  # tests
  pytestCheckHook,
  pytest-benchmark,
  psutil,
  cffi,
  filecheck,
  ml-dtypes,
  statistics,

  # passthru
  numba-cuda,
}:

buildPythonPackage (finalAttrs: {
  pname = "numba-cuda";
  version = "0.30.2";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "numba-cuda";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/oaVg3fFlkSmZueq1A6NRI5RjomwKgjiquKe98yDwtA=";
  };

  # NVRTC and cuda-pathfinder use CUDA_HOME at runtime to find headers
  # and libraries for JIT compilation.
  env.CUDA_HOME = symlinkJoin {
    name = "cuda-redist";
    paths =
      with cudaPackages;
      [
        (lib.getInclude cuda_cudart) # cuda_runtime.h, cuda.h
        (lib.getInclude cuda_nvrtc) # nvrtc.h
        (lib.getLib cuda_nvrtc) # libnvrtc.so
        (lib.getInclude cuda_cccl) # cuda/std, cuda/atomic, nv/target
      ]
      ++ lib.optionals (cudaPackages.cudaAtLeast "13.0") [
        (lib.getInclude cudaPackages.cuda_crt)
      ]
      ++ lib.optionals (cudaPackages.cudaOlder "13.0") [
        (lib.getInclude cudaPackages.cuda_nvcc)
        cudaPackages.cuda_nvcc # provides nvvm/libnvvm.so etc
      ];
  };

  build-system = [
    setuptools
    wheel
    numpy
  ];

  dependencies = [
    numpy
    numba
    packaging
    cuda-bindings
    cuda-pathfinder
    cuda-core
  ];

  # The test suite requires a GPU.
  doCheck = false;

  preCheck = ''
    cp -r numba_cuda/numba/cuda/tests tests
    rm -rf numba_cuda
    mkdir -p _redirect/numba
    numba_src=$(python -c 'import numba; print(numba.__path__[0])')
    cp -r "$numba_src"/* _redirect/numba/
    chmod -R u+w _redirect/numba/cuda
    rm -rf _redirect/numba/cuda
    ln -sfT $out/${python.sitePackages}/numba_cuda/numba/cuda _redirect/numba/cuda
    export PYTHONPATH="$(pwd)/_redirect:$PYTHONPATH"
    # numba-cuda looks for libcuda.so.1 in /usr/lib; NixOS puts it elsewhere.
    # libnvvm.so lives in nvvm/lib/ which the linker doesn't search by default.
    export LD_LIBRARY_PATH="$CUDA_HOME/nvvm/lib:/run/opengl-driver/lib:$LD_LIBRARY_PATH"
  '';

  pytestFlags = [
    "--ignore=_redirect"
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-benchmark
    psutil
    cffi
    filecheck
    ml-dtypes
    statistics
  ];

  pythonImportsCheck = [
    "numba_cuda"
    "numba.cuda"
  ];

  passthru.gpuCheck = numba-cuda.overridePythonAttrs {
    __noChroot = true;
    doCheck = true;
  };

  meta = with lib; {
    description = "CUDA target for Numba";
    homepage = "https://github.com/NVIDIA/numba-cuda";
    license = licenses.bsd2;
    platforms = platforms.linux;
  };
})
