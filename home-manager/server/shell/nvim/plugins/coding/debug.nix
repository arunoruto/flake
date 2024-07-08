{pkgs, ...}: {
  programs.nixvim = {
    plugins.dap = {
      enable = true;
      extensions.dap-ui = {
        enable = true;
      };
    };
    keymaps = [
      {
        mode = ["n"];
        key = "<leader>db";
        action = "<cmd>DapToggleBreakpoint<cr>";
        options = {
          silent = true;
          desc = "Toggle Breakpoint";
        };
      }
      {
        mode = ["n"];
        key = "<leader>dpr";
        action.__raw = ''function() require("dap-python").test_method() end'';
        options = {
          silent = true;
          desc = "Toggle Breakpoint";
        };
      }
    ];
    extraPlugins = with pkgs; [
      vimPlugins.nvim-dap-ui
      vimPlugins.nvim-dap-python
    ];
    extraConfigLua = ''
      require("lz.n").load {
        {
          "nvim-dap",
          cmd = "DapToggleBreakpoint",
        },
        --{
        --  "nvim-dap-ui",
        --  after = function ()
        --    require("dap").setup()
        --  end,
        --},
        --{
        --  "nvim-dap-python",
        --  after = function ()
        --    require("dap").setup()
        --  end,
        --}
      }
    '';
  };
}
