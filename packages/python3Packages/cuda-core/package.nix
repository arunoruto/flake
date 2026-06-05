{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,

  cython,
  cudaPackages,
  symlinkJoin,

  # build-system
  setuptools,
  setuptools-scm,

  # dependencies
  cuda-bindings,
  cuda-pathfinder,

  # tests
  pytest-mock,
  pytest-benchmark,
  pytest-rerunfailures,
  pytest-randomly,
  pytest-repeat,
  cloudpickle,
  psutil,
  cffi,
  pytestCheckHook,

  # passthru
  cuda-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "cuda-core";
  version = "1.0.1";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "cuda-python";
    tag = "cuda-core-v${finalAttrs.version}";
    hash = "sha256-SRy/hnOzzb4wUCLOre4k326RNhYI0650XzC8Dc9kf/M=";
  };

  sourceRoot = "${finalAttrs.src.name}/cuda_core";

  # NVIDIA's build_hooks.py looks for CUDA_HOME to find include/cuda.h
  # NVRTC also uses CUDA_HOME at runtime to find headers for JIT compilation
  env.CUDA_HOME = symlinkJoin {
    name = "cuda-redist";
    paths =
      with cudaPackages;
      [
        (lib.getInclude cuda_cudart) # cuda_runtime.h, cuda.h
        (lib.getInclude cuda_nvrtc) # nvrtc.h
        (lib.getInclude cuda_profiler_api) # cudaProfiler.h
        (lib.getInclude cuda_cccl) # cuda/std, cuda/atomic, nv/target
      ]
      ++ lib.optionals (cudaPackages.cudaAtLeast "13.0") [
        (lib.getInclude cudaPackages.cuda_crt) # crt/host_defines.h
      ]
      ++ lib.optionals (cudaPackages.cudaOlder "13.0") [
        (lib.getInclude cudaPackages.cuda_nvcc) # crt headers (CUDA < 13)
      ];
  };

  build-system = [
    setuptools
    setuptools-scm
    cython
  ];

  buildInputs = [
    cudaPackages.cuda_cudart
    cudaPackages.cuda_cccl
    cudaPackages.cuda_profiler_api
    cudaPackages.cuda_nvrtc
  ]
  ++ lib.optionals (cudaPackages.cudaOlder "13.0") [
    cudaPackages.cuda_nvcc
  ]
  ++ lib.optionals (cudaPackages.cudaAtLeast "13.0") [
    cudaPackages.cuda_crt
  ];

  dependencies = [
    cuda-bindings
    cuda-pathfinder
  ];

  postPatch = ''
    # Fix namespace shadowing
    sed -i "1i import sys; sys.path.insert(1, '${cuda-pathfinder}/lib/${python.libPrefix}/site-packages')" build_hooks.py
  '';

  pythonImportsCheck = [
    "cuda.core"
  ];

  doCheck = false;

  preCheck = ''
    rm -rf cuda
  '';

  nativeCheckInputs = [
    pytest-mock
    pytest-benchmark
    pytest-rerunfailures
    pytest-randomly
    pytest-repeat
    cloudpickle
    psutil
    cffi
    pytestCheckHook
  ];

  passthru.gpuCheck = cuda-core.overridePythonAttrs {
    __noChroot = true;
    doCheck = true;
    disabledTests = [
      # Uses __nanosleep which isn't available in CUDA 12.x CRT headers
      "test_event_is_done_false"
      # Requires >= 2 SMs
      "test_discovery_mode"
      "test_discovery_respects_alignment"
      # Spawns subprocesses that lose PYTHONPATH in __noChroot mode
      "test_patched_completion_succeeds_on_non_ipc_resource"
      "test_opt_out_env_var_disables_patch_even_when_interactive"
    ];
  };

  meta = {
    description = "Pythonic access to CUDA Runtime and other core functionality";
    homepage = "https://github.com/NVIDIA/cuda-python/tree/main/cuda_core";
    platforms = lib.platforms.linux;
  };
})
