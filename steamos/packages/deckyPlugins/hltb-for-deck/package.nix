{
  lib,
  buildDeckyPlugin,
  nix-update-script,
}:

buildDeckyPlugin {
  pname = "hltb-for-deck";
  version = "2.0.9";
  owner = "morwy";
  hash = "sha256-3hFEQu1OQQKN8dOUHNFtre8GVI8RC4XRlQeW4C0Wyhw=";

  # Also set by buildDeckyPlugin; repeated here because the repo requires
  # every package.nix to opt in visibly (scripts/check-new-packages.sh).
  __structuredAttrs = true;
  strictDeps = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Decky plugin showing game lengths from How Long To Beat";
    license = lib.licenses.bsd3;
  };
}
