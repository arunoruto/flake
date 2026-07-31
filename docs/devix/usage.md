# Usage

## Getting started

devix is a Home Manager module. Import it, turn it on, and enable the languages
you want:

```nix
{
  imports = [ inputs.flake.homeModules.devix ];

  devix = {
    enable = true;
    defaultEditor = "helix";
    languages = {
      nix.enable = true;
      python.enable = true;
      rust.enable = true;
    };
  };

  programs.helix.enable = true;
}
```

Enabling the editor is all that is needed for devix to configure it —
`devix.consumers.helix.enable` defaults to
`devix.autoEnable && programs.helix.enable`. Set `devix.autoEnable = false` if
you would rather opt each consumer in by hand.

`defaultEditor` sets `EDITOR` and `VISUAL`. Only consumers that are actual
editors are candidates; an AI harness like OpenCode is not offered.

The language servers and formatters a language references are installed for
you — there is no separate `home.packages` entry to maintain.

## Adding an addon

```nix
devix.addons.grammar.enable = true;
```

This attaches `ltex` and `codebook` to markdown, LaTeX and Typst wherever those
are enabled. To change what it attaches or where:

```nix
devix.addons.grammar = {
  enable = true;
  lspServers = [ "codebook" ];          # drop ltex, it is heavy
  languages = [ "markdown" "typst" ];   # leave LaTeX alone
};
```

## Overriding a server

Servers live in a shared registry, so an override applies to every consumer at
once. Change its settings:

```nix
devix.lsps.pyright.config.python.analysis.typeCheckingMode = "basic";
```

Change which build is used — `command` follows `package`, so this is enough:

```nix
devix.lsps.nixd.package = pkgs.unstable.nixd;
```

Turn one off everywhere without touching the language:

```nix
devix.lsps.markdown-oxide.enable = false;
```

## Turning things off per editor

Every language, addon, server and formatter has a per-consumer toggle. They all
default to enabled, so you only write the exceptions.

```nix
# Zed has good built-in Markdown support; keep devix out of it
devix.languages.markdown.consumers.zed.enable = false;

# Grammar servers are useful in the editor, noise in the AI harness
devix.addons.grammar.consumers.opencode.enable = false;

# One server, one editor
devix.lsps.ltex.consumers.zed.enable = false;
```

Note the difference between this and `devix.lsps.<name>.enable = false`: the
latter switches the server off everywhere, the former only hides it from one
consumer.

## Changing a language's servers

`lspServers` and `formatters` are lists of registry keys, so you can reorder,
extend or replace them:

```nix
devix.languages.python = {
  enable = true;
  lspServers = [ "pyright" "ruff" ];   # add a second server
  formatters = [ "ruff-format" ];      # drop the import-sorting pass
};
```

Referencing a name that no registry entry defines is caught with a clear
message rather than an obscure evaluation failure:

```text
devix.languages / devix.addons reference unknown LSPs: ruff
```

## Migrating from `development.*`

Options used to live under `development.*`, and `autoEnable` used to be called
`autoConfigureEditors`. The old names still work and warn:

```text
The option `development.languages.rust' has been renamed to `devix.languages.rust'.
```

The aliases live in `modules/devix/core/renames.nix` and can be deleted once
nothing refers to the old paths.
