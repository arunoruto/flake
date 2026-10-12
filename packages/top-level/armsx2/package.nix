{
  lib,
  stdenv,
  fetchFromGitHub,
  pcsx2,
  darwin,
  freetype,
  makeWrapper,
  moltenvk,
  nix-update-script,
  # The ARM64 memory manager bakes in the page size and must match the
  # running kernel. 4 KiB fits the Raspberry Pi and most ARM boards; Asahi
  # Linux and macOS on Apple Silicon need 16384. Left to itself, CMake would
  # probe the build machine instead.
  hostPageSize ? if stdenv.hostPlatform.isDarwin then 16384 else 4096,
  hostCacheLineSize ? if hostPageSize == 16384 then 128 else 64,
  # macOS only: the Xcode whose Metal compiler builds the shaders (see below).
  xcodeDeveloperDir ? "/Applications/Xcode.app/Contents/Developer",
}:

# ARMSX2 is PCSX2 with ARM64 recompilers; it keeps PCSX2's dependency set,
# PACKAGE_MODE install layout and wrapper, so only the deltas live here.
# macOS builds the app bundle instead, from the same override.
pcsx2.overrideAttrs (
  finalAttrs: prevAttrs:
  let
    inherit (stdenv.hostPlatform) isDarwin;
    # The system xcrun, pointed at Xcode rather than the Nix SDK.
    xcrun = "/usr/bin/env -u SDKROOT DEVELOPER_DIR=${xcodeDeveloperDir} /usr/bin/xcrun";
  in
  {
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
    ''
    + lib.optionalString isDarwin ''
      substituteInPlace pcsx2/CMakeLists.txt \
        --replace-fail 'COMMAND xcrun ' 'COMMAND ${xcrun} '
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
      lib.filter (
        flag:
        !lib.hasPrefix "-DUSE_LINKED_FFMPEG" flag
        # On macOS resources live in the bundle, not in share/PCSX2.
        && !(isDarwin && lib.hasPrefix "-DPACKAGE_MODE" flag)
      ) prevAttrs.cmakeFlags
      # macOS picks its own -march (armv8.4-a for the M1 and up).
      ++ lib.optionals (!isDarwin) [
        (lib.cmakeFeature "CMAKE_C_FLAGS" targetFlags)
        (lib.cmakeFeature "CMAKE_CXX_FLAGS" targetFlags)
      ]
      ++ [
        (lib.cmakeFeature "HOST_PAGE_SIZE" (toString hostPageSize))
        (lib.cmakeFeature "HOST_CACHE_LINE_SIZE" (toString hostCacheLineSize))
        (lib.cmakeBool "ENABLE_TESTS" false)
      ]
      # macdeployqt would copy Qt into the bundle; Nix provides it instead.
      ++ lib.optionals isDarwin [ (lib.cmakeBool "SKIP_POSTPROCESS_BUNDLE" true) ];

    # pcsx2 passes each wrapper flag as one space-separated string, which
    # only works when the shell word-splits it; structured attrs don't.
    qtWrapperArgs = lib.concatMap (lib.splitString " ") prevAttrs.qtWrapperArgs;

    # No video capture (so no FFmpeg) on Linux, and rapidyaml is vendored.
    # macOS drops the Linux desktop integration (and the debugger's
    # KDDockWidgets, which ARM64 builds leave out), names FreeType itself
    # (Linux gets it through GTK) and bundles MoltenVK for the Vulkan renderer.
    buildInputs =
      lib.filter (
        dep:
        !lib.elem (lib.getName dep) (
          [
            "ffmpeg"
            "rapidyaml"
          ]
          ++ lib.optionals isDarwin [
            "gtk+3"
            "KDDockWidgets"
            "libaio"
            "libbacktrace"
            "libxrandr"
            "qtwayland"
            "wayland"
          ]
        )
      ) prevAttrs.buildInputs
      ++ lib.optionals isDarwin [
        freetype
        moltenvk
      ];

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
      platforms = [
        "aarch64-darwin"
        "aarch64-linux"
      ];
    };
  }
  // lib.optionalAttrs isDarwin {
    # Upstream compiles the Metal shaders with Apple's `metal`, which only
    # ships with Xcode, so this build uses the system Xcode: it needs the
    # Nix sandbox off or relaxed, and Xcode with its Metal toolchain on the
    # build machine.
    __noChroot = true;

    nativeBuildInputs =
      lib.filter (dep: lib.getName dep != "wrap-gapps-hook") prevAttrs.nativeBuildInputs
      ++ [
        darwin.autoSignDarwinBinariesHook
        makeWrapper
      ];

    preConfigure = ''
      # The Metal compiler keeps a cache in $HOME.
      export HOME=$TMPDIR
      if ! ${xcrun} metal -v >/dev/null 2>&1; then
        echo "error: no Metal compiler in ${xcodeDeveloperDir}." >&2
        echo "Install Xcode, then run 'sudo xcodebuild -license accept' and" >&2
        echo "'xcodebuild -downloadComponent MetalToolchain'." >&2
        exit 1
      fi
    '';

    qtWrapperArgs = [ ];
    preFixup = "";

    # Apple builds leave the bundle in the build tree instead of installing it.
    postInstall = ''
      mkdir -p $out/Applications
      cp -r pcsx2-qt/ARMSX2.app $out/Applications/
      app=$out/Applications/ARMSX2.app

      zip -jq $app/Contents/Resources/patches.zip ${prevAttrs.passthru.pcsx2_patches}/patches/*
      strip-nondeterminism $app/Contents/Resources/patches.zip

      # The bundled shaderc and MoltenVK keep their executable bit, which
      # would get them wrapped by wrapQtAppsHook like the app itself.
      chmod -x $app/Contents/Frameworks/*.dylib

      # Run the bundle from its own path so it finds its resources.
      makeWrapper $app/Contents/MacOS/ARMSX2 $out/bin/armsx2-qt
    '';
  }
)
