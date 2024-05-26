{
  programs.nixvim = {
    plugins = {
      nvim-autopairs = {
        enable = true;
        checkTs = true;
        #tsConfig = {
        #  lua = [ "string" ];
        #  javascript = [ "template_string" ];
        #};
      };
    };
  };
}
