{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.nixvim = {
    plugins = {
      lsp-format.enable = true;
      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          julials.enable = true;
          marksman.enable = true;
          lua-ls.enable = true;
          # Docker
          dockerls.enable = true;
          docker-compose-language-service.enable = true;
          # Python
          pyright.enable = true;
          ruff.enable = true;
          # ruff-lsp.enable = true;
          # Web & co.
          tsserver.enable = true;
          eslint.enable = true;
          html.enable = true;
          cssls.enable = true;
          tailwindcss.enable = true;
          # Markups
          jsonls.enable = true;
          yamlls.enable = true;
          # Nix
          nil-ls.enable = true;
          nixd.enable = true;
          # Tex
          ltex = {
            enable = true;
            settings = {
              language = "en-US";
              ltex-ls.path = "${pkgs.ltex-ls}";
              additionalRules.languageModel = "~/.cache/ngrams";
            };
          };
          texlab.enable = true;
        };
        keymaps = {
          silent = true;
          lspBuf = {
            gd = {
              action = "definition";
              desc = "Goto Definition";
            };
            gr = {
              action = "references";
              desc = "Goto References";
            };
            gD = {
              action = "declaration";
              desc = "Goto Declaration";
            };
            gI = {
              action = "implementation";
              desc = "Goto Implementation";
            };
            gT = {
              action = "type_definition";
              desc = "Type Definition";
            };
            K = {
              action = "hover";
              desc = "Hover";
            };
            "<leader>cw" = {
              action = "workspace_symbol";
              desc = "Workspace Symbol";
            };
            "<leader>cr" = {
              action = "rename";
              desc = "Rename";
            };
          };
          diagnostic = {
            "<leader>dl" = {
              action = "open_float";
              desc = "Line Diagnostics";
            };
            "<leader>dn" = {
              action = "goto_next";
              desc = "Next Diagnostic";
            };
            "<leader>dp" = {
              action = "goto_prev";
              desc = "Previous Diagnostic";
            };
          };
        };
      };
    };
    extraConfigLua = ''
      -- used to enable autocompletion (assign to every lsp server config)
      -- local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }

      local language_servers = require("lspconfig").util.available_servers()
      for _, ls in ipairs(language_servers) do
          require('lspconfig')[ls].setup({
              capabilities = capabilities
          })
      end

      -- -- list all LSPs from above
      -- local lsps = {${lib.concatMapStringsSep "," (x: ''"${x}"'') (lib.filter (server: config.programs.nixvim.plugins.lsp.servers."${server}".enable) (lib.attrNames config.programs.nixvim.plugins.lsp.servers))}}
      -- for i, v in ipairs(lsps) do
      --   lsps[i] = lsps[i]:gsub("-", "_")
      --   -- if v == "ruff-lsp" then
      --   --   lsps[i] = "ruff_lsp"
      --   -- elseif v == "lua-ls" then
      --   --   lsps[i] = "lua_ls"
      --   -- end
      -- end

      -- print(unpack(require("lspconfig").util.available_servers()))

      -- -- combinatination what been done in:
      -- -- joseans blog: https://www.josean.com/posts/how-to-setup-neovim-2024 (nvim-lspconfig section)
      -- -- and in this config: https://github.com/pete3n/nixvim-flake/blob/main/config/lsp.nix
      -- for _, lsp in pairs(lsps) do
      --   require("lspconfig")[lsp].setup({
      --     capabilities = capabilities,
      --   })
      -- end

      local _border = "rounded"

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = _border
        }
      )

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
          border = _border
        }
      )

      vim.diagnostic.config{
        float={border=_border}
      };

      require('lspconfig.ui.windows').default_options = {
        border = _border
      }
    '';
  };
  home = {
    packages = with pkgs; [
      ltex-ls
    ];

    file = {
      ".cache/ngrams/de".source = pkgs.fetchzip {
        url = "https://languagetool.org/download/ngram-data/ngrams-de-20150819.zip";
        hash = "sha256-b+dPqDhXZQpVOGwDJOO4bFTQ15hhOSG6WPCx8RApfNg=";
      };
      ".cache/ngrams/en".source = pkgs.fetchzip {
        url = "https://languagetool.org/download/ngram-data/ngrams-en-20150817.zip";
        hash = "sha256-v3Ym6CBJftQCY5FuY6s5ziFvHKAyYD3fTHr99i6N8sE=";
      };
    };
  };
}
