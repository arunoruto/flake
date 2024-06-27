{
  imports = [
    #./headlines.nix
    ./glow.nix
    ./neorg.nix
  ];

  programs.nixvim = {
    plugins = {
      markdown-preview.enable = true;
    };
  };
}
