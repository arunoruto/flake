{pkgs, ...}: {
  programs.nixvim = {
    plugins = {
      cmp-emoji.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp_luasnip.enable = true;
      cmp-cmdline.enable = true;
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          experimental.ghost_text = true;
          performance = {
            debounce = 60;
            fetchingTimeout = 200;
            #maxViewEntries = 30;
          };
          snippet.expand = "luasnip";
          formatting.fields = ["kind" "abbr" "menu"];
          sources = [
            {name = "nvim_lsp";}
            {name = "emoji";}
            {
              name = "buffer";
              keywordLength = 3;
              option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
            }
            {
              name = "path";
              keywordLength = 3;
            }
            {
              name = "luasnip";
              keywordLength = 3;
            }
            # {name = "copilot";}
          ];
          #settings = {
          #  completion.completeopt = "menu,menuone,preview,noselect";
          #  snippet.expand = ''
          #    function(args)
          #      require('luasnip').lsp_expand(args.body)
          #    end
          #  '';
          #};
          completion.completeopt = "menu,menuone,preview,noselect";
          #snippet.expand = {
          #  __raw = ''
          #    function(args)
          #      require('luasnip').lsp_expand(args.body)
          #    end
          #  '';
          #};

          window = {
            completion.border = "solid";
            documentation.border = "solid";
          };

          mapping = {
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<C-k>" = "cmp.mapping.select_prev_item()"; # previous suggestion
            "<C-j>" = "cmp.mapping.select_next_item()"; # next suggestion
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })"; # close completion window
            "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
            "<C-Space>" = "cmp.mapping.complete()"; # show completion suggestions
          };
          #formatting.format = ''
          #  require("lspkind").cmp_format({
          #    maxwidth = 50,
          #    ellipsis_char = "...",
          #  })
          #'';
        };
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      friendly-snippets # useful snippets
    ];
    extraConfigLua = ''
      -- lazy load
      require("lz.n").load({
        {
          "nvim-cmp",
          -- load cmp on InsertEnter
          event = "InsertEnter",
        }
      })

      -- require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
      -- luasnip = require("luasnip")
      kind_icons = {
        Text = "󰊄",
        Method = "",
        Function = "󰡱",
        Constructor = "",
        Field = "",
        Variable = "󱀍",
        Class = "",
        Interface = "",
        Module = "󰕳",
        Property = "",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = "",
      }

      -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
      require("cmp").setup.cmdline({'/', "?" }, {
        sources = {
          { name = 'buffer' }
        }
      })

      -- Set configuration for specific filetype.
      require("cmp").setup.filetype('gitcommit', {
        sources = require("cmp").config.sources({
          { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
        }, {
          { name = 'buffer' },
        })
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      require("cmp").setup.cmdline(':', {
        sources = require("cmp").config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        }),
        -- formatting = {
        --   format = function(_, vim_item)
        --     vim_item.kind = cmdIcons[vim_item.kind] or "FOO"
        --   return vim_item
        --  end
        -- }
      })
    '';
  };
}
