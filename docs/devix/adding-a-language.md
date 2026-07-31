# Adding a language

Create one file in `modules/devix/languages/`. The directory is scanned, so
there is no list to update and no module to write — the file becomes a
`devix.languages.<name>` option automatically, named after the file.

## The shape

```nix
# modules/devix/languages/zig.nix
{ lib, pkgs }:

{
  description = "Zig development environment";

  lsps.zls = {
    enable = true;
    package = pkgs.zls;
  };

  formatters.zig-fmt = {
    enable = true;
    package = pkgs.zig;
    command = lib.getExe' pkgs.zig "zig";
    args = [ "fmt" "--stdin" ];
  };

  language = {
    lspServers = [ "zls" ];
    formatters = [ "zig-fmt" ];
    tabWidth = 4;
    insertSpaces = true;
    roots = [ "build.zig" ];
  };

  consumerMeta.zed = {
    name = "Zig";
    extensions = [ "zig" ];
    languageServers = [ "zls" "..." ];
  };

  consumerMeta.opencode.extensions = [ ".zig" ];
}
```

That is the entire change. `devix.languages.zig` now exists, defaulted from
this file, and every consumer picks it up.

## Field by field

**`description`** — optional; shown in the generated option reference.

**`lsps` / `formatters`** — definitions that go into the shared registries.
`command` is derived from `package`, so you normally omit it. Set it explicitly
only when the binary is not the package's main program, as with the
`lib.getExe'` call above.

**`language.lspServers` / `language.formatters`** — which registry entries this
language uses, by name. A language may define more than it uses; the extras stay
available for users to opt into. Multiple formatters are piped in order.

**`language.roots`** — files that mark a project root, for consumers that
support the notion.

**`consumerMeta.<consumer>`** — how a `"meta"` consumer should handle this
language. Omit it and that consumer simply skips the language. The shape is
typed by each consumer's `metaOptions`, so mistakes fail the build:

- `zed` — `name` is Zed's display name and becomes the settings key.
  `languageServers` is a *curated, ordered* list; the literal `"..."` means
  "then Zed's own defaults". Omitting a devix server here is how you let Zed use
  its built-in support instead.
- `opencode` — `extensions` are the file extensions, with leading dots.

Helix needs no metadata: it declares `capability = "all"` and configures
languages generically.

## Rules

**Use plain `pkgs`.** Language files must not reference this flake's overlays —
no `pkgs.unstable`, no `pkgs.custom`. devix is exported as a standalone module
and has to evaluate against stock nixpkgs. "Use the unstable build" is a policy
decision and belongs in `modules/home-manager/development/`:

```nix
devix.lsps.zls.package = pkgs.unstable.zls;
```

**Do not enable anything.** A language file describes; it never decides. Turning
`zig` on for development machines is policy.

**Keep it data.** No `config`, no `lib.mkIf`, no reading the user's settings.
The file receives `lib` and `pkgs`, and returns an attribute set.

## Checking your work

```sh
# does everything still evaluate?
nix eval .#homeConfigurations.<user>.activationPackage.drvPath

# what did the consumers make of it?
nix eval .#homeConfigurations.<user>.config.programs.helix.languages --json | jq

# rebuild the generated reference and matrix
nix build .#docs-devix-reference && cat result/support-matrix.md
```

Your language should appear in the [support matrix](./reference/support-matrix.md)
with a mark under each consumer that covers it.
