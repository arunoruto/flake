# Home-manager integration for development language profiles
{ ... }:
{
  imports = [
    ../../languages/core.nix
    ../../languages/nix.nix
    ../../languages/python.nix
    ../../languages/json.nix
    ../../languages/yaml.nix
    ../../languages/toml.nix
    ../../languages/xml.nix
    ../../languages/markdown.nix
    ../../languages/typst.nix
    ../../languages/latex.nix
    ../../languages/bash.nix
    ../../languages/fish.nix
    ../../languages/nu.nix
    ../../languages/go.nix
    ../../languages/fortran.nix
    ../../languages/julia.nix
    ../../languages/matlab.nix
    ../../languages/grammar.nix
    ../../languages/ai.nix
    ./languages.nix
    ./editor-env.nix
    ./helix.nix
    ./zed.nix
  ];
}
