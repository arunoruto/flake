{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      actions-preview-nvim
    ];
    keymaps = [
      {
        mode = ["n" "v"];
        key = "<leader>fa";
        action = ''require("actions-preview").code_actions'';
        lua = true;
        options = {
          desc = "Display code actions in telescope";
          silent = true;
        };
      }
    ];
    extraConfigLua = ''
    '';
  };
}
