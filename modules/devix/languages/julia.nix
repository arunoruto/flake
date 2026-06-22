import ../lib/mkLanguage.nix {
  name = "julia";
  libPath = ../lib/julia.nix;
  description = "Julia development environment";
}
