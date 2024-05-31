{
  programs.nixvim = {
    plugins = {
      nvim-autopairs = {
        enable = true;
        settings = {
          check_ts = true;
        };
        #tsConfig = {
        #  lua = [ "string" ];
        #  javascript = [ "template_string" ];
        #};
      };
    };
  };
}
