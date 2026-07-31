# Adding an editor

A consumer is one directory under `modules/devix/consumers/`. The directory is
discovered automatically, and everything derived from it — the consumer list,
the per-item exposure toggles, the `defaultEditor` candidates, the
`EDITOR`/`VISUAL` map, the adapter lists both targets assemble from — follows
without you editing anything else.

```text
consumers/<name>/
  default.nix    what this consumer is (the registry entry)
  transform.nix  pure: resolved languages -> that tool's config format
  home.nix       Home Manager adapter
  devenv.nix     devenv adapter (optional)
```

## 1. The registry entry

```nix
# consumers/kakoune/default.nix
{
  description = "Kakoune text editor";

  # "all"  — configures languages generically, needs no per-language metadata
  # "meta" — only covers languages carrying consumerMeta.kakoune
  capability = "meta";

  # Types the `consumerMeta.kakoune` block in each language file. Required for
  # "meta" consumers; null for "all".
  metaOptions = lib: {
    filetypes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Kakoune filetype names for this language.";
    };
  };

  # When should this consumer switch itself on?
  activeWhen = config: config.programs.kakoune.enable or false;

  # Command for EDITOR/VISUAL, or null if this is not an interactive editor.
  editorCommand = "kak";

  home = ./home.nix;
  devenv = null;
}
```

Declaring `capability = "meta"` without `metaOptions` is rejected at evaluation
time, so the two cannot drift apart.

## 2. The transform

Keep this pure — it takes resolved languages and returns the tool's config.
Being a plain function of `lib` makes it easy to reason about and to reuse
across targets.

```nix
# consumers/kakoune/transform.nix
{ lib }:
let
  toKakoune = name: language: { ... };
in
{
  toKakouneConfig = languages: lib.mapAttrs toKakoune languages;
}
```

Languages arrive **already filtered and resolved**: only those enabled, exposed
to you, and supported by your capability model, with their server and formatter
lists already narrowed and the registry entries attached as `lsps` and
`formatterConfigs`. Do not re-implement that filtering — it lives in
`consumers/registry.nix` precisely so every consumer agrees.

## 3. The adapter

```nix
# consumers/kakoune/home.nix
{ config, lib, ... }:

let
  consumers = import ../registry.nix { inherit lib; };
  kakouneLib = import ./transform.nix { inherit lib; };

  cfg = config.devix;
  languages = consumers.languagesFor "kakoune" cfg.languages;
  resolved = consumers.resolveForConsumer "kakoune" cfg languages;
in
{
  config = lib.mkIf (cfg.enable && cfg.consumers.kakoune.enable && languages != { }) {
    programs.kakoune.settings = kakouneLib.toKakouneConfig resolved;
  };
}
```

The adapter does not need to enable itself — `targets/home/auto-enable.nix`
derives that from your `activeWhen` for every consumer at once.

## 4. Teach the languages about it

For a `"meta"` consumer, add a `consumerMeta.kakoune` block to each language it
should cover. Languages without one are skipped, which is a perfectly good
resting state — support can grow language by language, and the
[support matrix](./reference/support-matrix.md) shows the coverage at a glance.

## Checking your work

```sh
nix eval --impure --expr '
  let lib = (import <nixpkgs> {}).lib;
  in (import ./modules/devix/consumers/registry.nix { inherit lib; }).names'

nix eval .#homeConfigurations.<user>.config.programs.kakoune.settings --json | jq
```

Your consumer should appear in `names`, gain a column in the support matrix, and
show up as a toggle on every language, addon, server and formatter.
