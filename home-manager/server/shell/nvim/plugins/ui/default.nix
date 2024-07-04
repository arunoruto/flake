{pkgs, ...}: {
  imports = [
    ./alpha.nix
    #./baleia.nix
    ./lualine.nix
    # ./noice.nix
    # ./notify.nix
  ];

  programs.nixvim = {
    plugins = {
    };
    extraPlugins = with pkgs.vimPlugins; [
      nui-nvim
    ];
  };
}
