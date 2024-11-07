{
  programs.nixvim = {
    plugins = {
      trouble.enable = true;
    };
    keymaps = [
      {
        key = "<leader>xx";
        action = "<cmd>TroubleToggle<CR>";
        options.desc = "Open/close trouble list";
      }
      {
        key = "<leader>xw";
        action = "<cmd>TroubleToggle workspace_diagnostics<CR>";
        options.desc = "Open trouble workspace diagnostics";
      }
      {
        key = "<leader>xd";
        action = "<cmd>TroubleToggle document_diagnostics<CR>";
        options.desc = "Open trouble document diagnostics";
      }
      {
        key = "<leader>xq";
        action = "<cmd>TroubleToggle quickfix<CR>";
        options.desc = "Open trouble quickfix list";
      }
      {
        key = "<leader>xl";
        action = "<cmd>TroubleToggle loclist<CR>";
        options.desc = "Open trouble location list";
      }
      {
        key = "<leader>xt";
        action = "<cmd>TodoTrouble<CR>";
        options.desc = "Open todos in trouble";
      }
    ];
  };
}
