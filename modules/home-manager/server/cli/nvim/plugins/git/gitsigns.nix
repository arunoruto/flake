{
  programs.nixvim = {
    plugins = {
      gitsigns = {
        enable = true;
        settings.on_attach = ''
          function(bufnr)
            -- Navigation
            vim.keymap.set("n", "]h", require("gitsigns").next_hunk, { buffer = bufnr, desc = "Next hunk"})
            vim.keymap.set("n", "[h", require("gitsigns").prev_hunk, { buffer = bufnr, desc = "Previous hunk"})

            -- Actions hunk
            vim.keymap.set("n", "<leader>hs", require("gitsigns").stage_hunk, { buffer = bufnr, desc = "Stage hunk"})
            vim.keymap.set("n", "<leader>hr", require("gitsigns").reset_hunk, { buffer = bufnr, desc = "Reset hunk"})
            vim.keymap.set("v", "<leader>hs", function() require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { buffer = bufnr, desc = "Stage hunk in visual"})
            vim.keymap.set("v", "<leader>hs", function() require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { buffer = bufnr, desc = "Reset hunk in visual"})

            -- Actions buffer
            vim.keymap.set("n", "<leader>hS", require("gitsigns").stage_buffer, { buffer = bufnr, desc = "Stage buffer"})
            vim.keymap.set("n", "<leader>hR", require("gitsigns").reset_buffer, { buffer = bufnr, desc = "Reset buffer"})

            -- Buffer
            vim.keymap.set("n", "<leader>hb", function() require("gitsigns").blame_line({ full = true }) end, { buffer = bufnr, desc = "Blame line"})
            vim.keymap.set("n", "<leader>hB", require("gitsigns").toggle_current_line_blame, { buffer = bufnr, desc = "Toggle line blame"})

            -- Diffs
            vim.keymap.set("n", "<leader>hd", require("gitsigns").diffthis, { buffer = bufnr, desc = "Diff this"})
            vim.keymap.set("n", "<leader>hD", function() require("gitsigns").diffthis("~") end, { buffer = bufnr, desc = "Diff this ~"})

            -- Text object
            vim.keymap.set({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>", { buffer = bufnr, desc = "Gitsigns select hunk"})
          end
        '';
      };
    };
    #keymaps = [
    #  { mode = "n"; key = "<leader>cn"; action = ''function() require("todo-comments").jump_next() end''; lua = true; options = { silent = true; desc = "Next todo comment"; }; }
    #  { mode = "n"; key = "<leader>cp"; action = ''function() require("todo-comments").jump_prev() end''; lua = true; options = { silent = true; desc = "Previous todo comment"; }; }
    #  { mode = "n"; key = "<leader>ft"; action = "<cmd>TodoTelescope<CR>"; options = { silent = true; desc = "Find TODOs"; }; }
    #];
  };
}
