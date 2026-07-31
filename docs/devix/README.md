# devix

**Stylix, but for development environments.**

Stylix lets you declare a colour scheme once and have every program that
understands theming configure itself from it. devix does the same thing for
development tooling: you describe a *language* once — its language servers, its
formatters, how it should be indented — and every editor that understands the
description configures itself from it.

The problem it solves is duplication. Setting up Rust in Helix means writing a
`languages.toml` stanza. Setting up the same Rust in Zed means writing a
different stanza in `settings.json`. Doing it for an AI harness like OpenCode
means a third format. Three files, three syntaxes, one fact — which is exactly
the kind of thing Nix is supposed to abolish.

```nix
devix = {
  enable = true;
  languages.rust.enable = true;
};

programs.helix.enable = true;
programs.zed-editor.enable = true;
```

That is the whole configuration. Both editors get `rust-analyzer` wired up with
`rustfmt` on save and the right indentation, because both of them consume the
same description.

## Why editors are not the only consumers

Language servers used to be an editor concern. They are not anymore — coding
agents such as OpenCode and Claude Code benefit from exactly the same
information, because "which LSP understands this file, and what formats it"
is a fact about the project, not about the program looking at it.

devix calls anything that consumes the description a **consumer**. An editor is
a consumer. An AI harness is a consumer. Adding a new one does not require
touching a single language definition.

## Where to go next

- [Concepts](./concepts.md) — the four pieces devix is built from, and the two
  rules that decide what each consumer sees.
- [Usage](./usage.md) — turning things on, overriding servers, opting out.
- [Adding a language](./adding-a-language.md) and
  [adding an editor](./adding-an-editor.md).
- [Support matrix](./reference/support-matrix.md) — which languages each
  consumer covers, generated from the definitions themselves.
- Option reference: [core](./reference/core.md),
  [languages](./reference/languages.md), [addons](./reference/addons.md),
  [registries](./reference/registries.md) — generated from the option
  descriptions in `modules/devix`.

## Status

devix currently lives inside [this flake](https://github.com/arunoruto/flake)
as `modules/devix`, and is exported as `homeModules.devix` and
`devenvModules.*`. It has no dependency on the rest of the configuration: the
language definitions use plain `nixpkgs`, so the module works against a stock
home-manager setup. If it outgrows this repository it can move out as-is.
