{ lib, config, ... }@args:
{
  options.helix = {
    codebook.enable = lib.mkEnableOption "Codebook LSP (dev registry)";
    copilot.enable = lib.mkEnableOption "Copilot language server (dev registry)";
    shells.enable = lib.mkEnableOption "Shell language support (dev registry)";
    latex.enable = lib.mkEnableOption "LaTeX language support (dev registry)";
    markdown.enable = lib.mkEnableOption "Markdown language support (dev registry)";
    markup.enable = lib.mkEnableOption "Markup language support (dev registry)";
    nix.enable = lib.mkEnableOption "Nix language support (dev registry)";
    typst.enable = lib.mkEnableOption "Typst language support (dev registry)";
    python.enable = lib.mkEnableOption "Python language support (dev registry)";
    go.enable = lib.mkEnableOption "Go language support (dev registry)";
    julia.enable = lib.mkEnableOption "Julia language support (dev registry)";
    fortran.enable = lib.mkEnableOption "Fortran language support (dev registry)";
    matlab.enable = lib.mkEnableOption "Matlab language support (dev registry)";

    ltex = {
      enable = lib.mkEnableOption "LTeX support (dev registry)";
      ngram = lib.mkEnableOption "Setup ngrams for better grammar";
    };
    harper.enable = lib.mkEnableOption "Harper support (dev registry)";
  };

  config = {
    helix = {
      codebook.enable = lib.mkDefault false;
      copilot.enable = lib.mkDefault false;
      shells.enable = lib.mkDefault config.hosts.development.enable;
      latex.enable = lib.mkDefault config.hosts.development.enable;
      ltex = {
        enable = lib.mkDefault config.hosts.development.enable;
        ngram = lib.mkDefault (config.hosts.development.enable && (args ? nixosConfig));
      };
      markdown.enable = lib.mkDefault true;
      markup.enable = lib.mkDefault true;
      nix.enable = lib.mkDefault true;
      typst.enable = lib.mkDefault config.hosts.development.enable;
      python.enable = lib.mkDefault config.hosts.development.enable;
      go.enable = lib.mkDefault config.hosts.development.enable;
      julia.enable = lib.mkDefault false;
      fortran.enable = lib.mkDefault config.hosts.development.enable;
      matlab.enable = lib.mkDefault config.hosts.development.enable;
      harper.enable = lib.mkDefault false;
    };
  };
}
