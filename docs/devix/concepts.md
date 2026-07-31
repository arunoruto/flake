# Concepts

devix is built from four pieces. Three of them are things you write; the fourth
is the machinery that connects them.

```text
languages/<lang>.nix   pure data: lsps, formatters, indentation, consumerMeta
addons/<addon>.nix     server groups that attach to languages (grammar, ai)
        │
        ▼
devix.lsps / devix.formatters             shared registries
devix.languages.<lang> / .addons.<addon>  what is on
        │
        ▼
consumers/registry.nix   applies exposure + capability, resolves per consumer
        │
        ├─ consumers/helix/    → programs.helix.languages
        ├─ consumers/zed/      → programs.zed-editor.userSettings
        └─ consumers/opencode/ → programs.opencode.settings
```

## Languages

A language is one file in `modules/devix/languages/`, and it is pure data — no
conditionals, no references to your configuration:

```nix
{ lib, pkgs }:
{
  lsps.tinymist = {
    enable = true;
    package = pkgs.tinymist;
  };

  formatters.typstyle = {
    enable = true;
    package = pkgs.typstyle;
  };

  language = {
    lspServers = [ "tinymist" ];
    formatters = [ "typstyle" ];
    tabWidth = 2;
    insertSpaces = true;
  };

  consumerMeta.zed = {
    name = "Typst";
    extensions = [ "typst" ];
    languageServers = [ "tinymist" "..." ];
  };

  consumerMeta.opencode.extensions = [ ".typ" ];
}
```

Adding a file to that directory is all it takes — the directory is scanned, and
each file becomes a `devix.languages.<name>` option. There is no list to update.

## Registries

Notice that the language above refers to its server as the *string*
`"tinymist"`, not as the definition directly. Server and formatter definitions
go into two shared registries, `devix.lsps` and `devix.formatters`, and
languages reference them by name.

That indirection is what makes overrides work in one place:

```nix
devix.lsps.pyright.config.python.analysis.typeCheckingMode = "basic";
```

Every consumer that uses pyright now uses that setting. If each language
embedded its servers directly, you would be overriding the same thing once per
editor — the duplication devix exists to remove.

A server's `command` is derived from its `package`, so swapping a build is one
line and every consumer follows:

```nix
devix.lsps.nixd.package = pkgs.unstable.nixd;
```

## Addons

Some servers are not tied to a language. Spell and grammar checking applies to
prose formats; AI completion applies to everything. Making them languages would
be a lie — and would leak a phantom "grammar" entry into your editor's language
list.

An addon is a group of servers plus the languages it attaches to:

```nix
{
  description = "spelling, grammar and style checking";
  lsps = { ltex = { ... }; codebook = { ... }; harper = { ... }; };
  lspServers = [ "ltex" "codebook" ];      # attached
  languages = [ "markdown" "latex" "typst" ];  # "*" for everything
}
```

Enabling it appends those servers to the languages named, wherever they are
enabled. Nothing appears in an editor as a language of its own.

## Consumers

A consumer is anything that reads the description and configures itself: an
editor, an AI harness. Each is one directory under `modules/devix/consumers/`,
containing what it is (`default.nix`), a pure transform into its config format
(`transform.nix`), and one adapter per target (`home.nix`, optionally
`devenv.nix`).

Consumers attach themselves the way Stylix targets do — enabling the program is
enough:

```nix
devix.consumers.<name>.enable   # defaults to
  devix.autoEnable && programs.<editor>.enable
```

## The two rules

Exactly two things decide what a given consumer sees, and both are applied in
one place (`consumers/registry.nix`) rather than by each adapter.

**Exposure** — every language, addon, server and formatter carries a
`consumers.<name>.enable` toggle, defaulting to `true`. This is how you say
"markdown's grammar servers everywhere, except in Zed".

**Capability** — what a consumer can handle at all. Each consumer declares one
of two models:

| `capability` | Meaning | Example |
|---|---|---|
| `"all"` | Configures languages generically; handles anything devix defines | Helix |
| `"meta"` | Only covers languages carrying `consumerMeta.<name>` | Zed, OpenCode |

Zed addresses languages by its own display name and curates its own server
list, so it cannot configure a language that has not told it how. OpenCode
attaches servers by file extension, so it needs to know the extensions. Helix
needs neither, so it takes everything.

A `"meta"` consumer also declares `metaOptions`, which *types* its slice of
`consumerMeta`. A typo or a wrong type in a language's metadata is a build
error rather than something silently ignored.

The [support matrix](./reference/support-matrix.md) shows the result of these
rules across every language currently defined.

## Mechanism and policy

devix itself enables nothing. It defines what a language *is* and how each
consumer should be configured — the mechanism. Deciding that Rust should be on
for development machines is policy, and in this flake it lives in
`modules/home-manager/development/`. Keeping the two apart is what lets devix
be lifted out of this repository unchanged.
