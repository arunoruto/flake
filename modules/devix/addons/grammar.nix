{ lib, pkgs }:

{
  description = "spelling, grammar and style checking";

  lsps = {
    ltex = {
      enable = true;
      package = pkgs.ltex-ls-plus;
      command = "ltex-ls-plus";
      config.ltex.language = "en-GB";
    };

    harper = {
      enable = true;
      package = pkgs.harper;
    };

    codebook = {
      enable = true;
      package = pkgs.codebook;
    };
  };

  # harper is defined but not attached by default: it overlaps codebook, and
  # running both means duplicate diagnostics. Add it to `lspServers` to switch.
  lspServers = [
    "ltex"
    "codebook"
  ];

  # Prose formats. Attaching these to code languages produces mostly noise.
  languages = [
    "markdown"
    "latex"
    "typst"
  ];
}
