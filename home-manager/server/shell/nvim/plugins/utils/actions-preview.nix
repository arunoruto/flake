{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      actions-preview-nvim
    ];
    keymaps = [
      {
        mode = ["n" "v"];
        key = "<leader>fa";
        action.__raw = ''require("actions-preview").code_actions'';
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
