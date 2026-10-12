{
  lib,
  stdenv,
  fetchFromGitHub,
  pcsx2,
  nix-update-script,
  # The ARM64 memory manager bakes in the page size and must match the
  # running kernel. 4 KiB fits the Raspberry Pi and most ARM boards; Asahi
  # Linux on Apple Silicon needs 16384. Left to itself, CMake would probe
  # the build machine instead.
  hostPageSize ? 4096,
  hostCacheLineSize ? if hostPageSize == 16384 then 128 else 64,
}:

# ARMSX2 is PCSX2 with ARM64 recompilers; it keeps PCSX2's dependency set,
# PACKAGE_MODE install layout and wrapper, so only the deltas live here.
pcsx2.overrideAttrs (
  finalAttrs: prevAttrs: {
    pname = "armsx2";
    version = "2.8.2";

    src = fetchFromGitHub {
      owner = "armsx2";
      repo = "armsx2";
      tag = finalAttrs.version;
      hash = "sha256-dk4+WJ6tmb4QrhMho32GQvj0FnVu8/aKiOFlwmQ0N64=";
    };

    # pcsx2's de-vendoring patch doesn't apply here (different context),
    # so swap the vendored cubeb for nixpkgs' the same way inline.
    patches = [ ];
    postPatch = ''
      substituteInPlace cmake/SearchForStuff.cmake \
        --replace-fail 'add_subdirectory(3rdparty/cubeb EXCLUDE_FROM_ALL)' \
                       'find_package(cubeb REQUIRED GLOBAL)
      add_library(cubeb ALIAS cubeb::cubeb)' \
        --replace-fail 'disable_compiler_warnings_for_target(cubeb)' "" \
        --replace-fail 'disable_compiler_warnings_for_target(speex)' ""
      # The page-size probe honours a preset but the cache-line probe always
      # measures the build machine (a qemu builder reports 32), so give it
      # the same early return.
      substituteInPlace cmake/Pcsx2Utils.cmake \
        --replace-fail 'set(PCSX2_GIT_TAG "")' 'set(PCSX2_GIT_TAG "${finalAttrs.src.tag}")' \
        --replace-fail 'message(STATUS "Determining host cache line size")' \
                       'if(DEFINED HOST_CACHE_LINE_SIZE)
        message(STATUS "Host cache line size (preset): ''${HOST_CACHE_LINE_SIZE}")
        return()
      endif()
      message(STATUS "Determining host cache line size")'
    '';

    # Upstream adds -march=armv8.1-a (LSE atomics) unless CMAKE_CXX_FLAGS
    # already names an -march, which SIGILLs on ARMv8.0 cores such as the
    # Pi 4's Cortex-A72. Follow the platform's target (armv8-a for plain
    # aarch64-linux); outline atomics still pick LSE where the CPU has it.
    # Structured attrs keep these space-separated flags in one argument.
    __structuredAttrs = true;
    strictDeps = true;

    cmakeFlags =
      let
        targetFlags = "-march=${stdenv.hostPlatform.gcc.arch or "armv8-a"} -moutline-atomics";
      in
      lib.filter (flag: !lib.hasPrefix "-DUSE_LINKED_FFMPEG" flag) prevAttrs.cmakeFlags
      ++ [
        (lib.cmakeFeature "CMAKE_C_FLAGS" targetFlags)
        (lib.cmakeFeature "CMAKE_CXX_FLAGS" targetFlags)
        (lib.cmakeFeature "HOST_PAGE_SIZE" (toString hostPageSize))
        (lib.cmakeFeature "HOST_CACHE_LINE_SIZE" (toString hostCacheLineSize))
        (lib.cmakeBool "ENABLE_TESTS" false)
      ];

    # pcsx2 passes each wrapper flag as one space-separated string, which
    # only works when the shell word-splits it; structured attrs don't.
    qtWrapperArgs = lib.concatMap (lib.splitString " ") prevAttrs.qtWrapperArgs;

    # No video capture (so no FFmpeg) on Linux, and rapidyaml is vendored.
    buildInputs = lib.filter (
      dep:
      !lib.elem (lib.getName dep) [
        "ffmpeg"
        "rapidyaml"
      ]
    ) prevAttrs.buildInputs;

    # Upstream CI ships a pcsx2_patches fork's rolling release; the pinned
    # official database nixpkgs' pcsx2 uses covers the same games.
    postInstall = ''
      install -Dm644 $src/pcsx2-qt/resources/icons/ARMSX2logo.png \
        $out/share/icons/hicolor/256x256/apps/ARMSX2.png
      install -Dm644 $src/.github/workflows/scripts/linux/armsx2-qt.desktop \
        $out/share/applications/ARMSX2.desktop

      zip -jq $out/share/PCSX2/resources/patches.zip ${prevAttrs.passthru.pcsx2_patches}/patches/*
      strip-nondeterminism $out/share/PCSX2/resources/patches.zip
    '';

    passthru = prevAttrs.passthru // {
      # Skip nightly-* and iOSv* tags.
      updateScript = nix-update-script {
        extraArgs = [ "--version-regex=^(\\d+\\.\\d+(?:\\.\\d+)*)$" ];
      };
    };

    meta = {
      homepage = "https://armsx2.net/";
      description = "PlayStation 2 emulator for ARM64, based on PCSX2";
      longDescription = ''
        ARMSX2 is a fork of the PCSX2 PlayStation 2 emulator that adds native
        ARM64 JIT recompilers (EE, IOP, VU0, VU1 and fastmem), where upstream
        PCSX2 only ships an interpreter for ARM.
      '';
      changelog = "https://github.com/armsx2/armsx2/releases/tag/${finalAttrs.src.tag}";
      downloadPage = "https://github.com/armsx2/armsx2";
      inherit (prevAttrs.meta) license;
      mainProgram = "armsx2-qt";
      maintainers = with lib.maintainers; [ arunoruto ];
      platforms = [ "aarch64-linux" ];
    };
  }
)
