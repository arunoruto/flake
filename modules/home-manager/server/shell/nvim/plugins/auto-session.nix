{
  programs.nixvim = {
    plugins = {
      auto-session = {
        enable = true;
        autoRestore.enabled = false;
        autoSession.suppressDirs = ["~/" "~/Dev/" "~/Downloads" "~/Documents" "~/Desktop/"];
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>wr";
        action = "<cmd>SessionRestore<CR>";
        options = {
          silent = true;
          desc = "Restore session for cwd";
        };
      }
      {
        mode = "n";
        key = "<leader>ws";
        action = "<cmd>SessionSave<CR>";
        options = {
          silent = true;
          desc = "Save session for auto session root dir";
        };
      }
    ];
  };
}
