{
  lib,
  buildDeckyPlugin,
  nix-update-script,
}:

buildDeckyPlugin {
  pname = "protondb-decky";
  version = "1.3.3";
  owner = "bschelst";
  hash = "sha256-xiLEgY90f629Yxuk+uBXFya/Gb0ytmHJ66d41T9Y/3c=";

  # Also set by buildDeckyPlugin; repeated here because the repo requires
  # every package.nix to opt in visibly (scripts/check-new-packages.sh).
  __structuredAttrs = true;
  strictDeps = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Decky plugin showing tappable ProtonDB badges on game pages";
    license = lib.licenses.bsd3;
  };
}
