
## Running from a Nix store

This copy of the skill is installed in the read-only Nix store, which changes
a few steps above:

- Never write inside the skill directory. The examples are already built, so
  open their `.html` pages directly. To rebuild or change an example, copy the
  whole skill first (`cp -rL --no-preserve=mode <skill dir> ./anatomy-work`)
  and work in the copy: the examples import `../../kit` and `../../scripts`.
- In a project, import the kit by its absolute path inside the skill
  directory, or copy `kit/` into the project.
- If `node` is not on `PATH`, run the scripts with
  `nix shell nixpkgs#nodejs -c node …`.
- The scripts only look for Chrome at fixed FHS paths. Set `CHROME_PATH`
  for `capture.mjs`, `drive.mjs`, `lines.mjs` and `turn-check.mjs`, for
  example `CHROME_PATH=$(command -v google-chrome-stable || command -v chromium)`.
