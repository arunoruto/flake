{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
  ...
}:
buildNpmPackage (finalAttrs: {
  pname = "flood";
  version = "0-unstable";

  src = fetchFromGitHub {
    owner = "deflating";
    repo = "tau";
    # tag = "v${finalAttrs.version}";
    rev = "2ee9daddc68f075568388f031397ec22c47889f7";
    hash = "";
  };

  npmDepsHash = "";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  # npmPackFlags = [ "--ignore-scripts" ];

  # NODE_OPTIONS = "--openssl-legacy-provider";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "${finalAttrs.pname}@(.*)"
    ];
  };

  meta = {
    description = "Web UI that mirrors your Pi terminal session in the browser";
    homepage = "https://github.com/deflating/tau";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ arunoruto ];
  };
})
