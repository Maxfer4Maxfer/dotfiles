return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {},
  },

  {
    "williamboman/mason-lspconfig.nvim",
  },

  -- LSP servers and formatters (conform.lua) from Mason; scripts/tools.sh runs
  -- :MasonToolsInstallSync. gopls and goimports come from packages/go.txt instead.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "pyright",
        "lua-language-server",
        "bash-language-server",
        "stylua",
        "prettier",
        "clang-format",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      {
        "j-hui/fidget.nvim",
        opts = {
          notification = {
            window = {
              winblend = 0,
              border = "single",
              align = "bottom",
            },
          },
        },
      },
    },

    config = function()
      require("mason-lspconfig").setup()

      -- LSP keymaps bound on attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("K",  vim.lsp.buf.hover,                                  "Hover Info")
          map("gl", function()
            vim.diagnostic.open_float(nil, {
              focusable = false, border = "single", source = "always", header = "", prefix = "",
            })
          end, "Line diagnostics")
          map("grn", vim.lsp.buf.rename,                                 "Rename")
          map("ga",  vim.lsp.buf.code_action,                            "Code Action", { "n", "x" })
          map("gr",  require("telescope.builtin").lsp_references,        "References")
          map("gi",  require("telescope.builtin").lsp_implementations,   "Implementations")
          map("gd",  require("telescope.builtin").lsp_definitions,       "Definition")
          map("gD",  vim.lsp.buf.declaration,                            "Declaration")
          map("gO",  require("telescope.builtin").lsp_document_symbols,  "Document Symbols")
          map("gW",  require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")
          map("grt", require("telescope.builtin").lsp_type_definitions,  "Type Definition")
        end,
      })

      -- Diagnostic appearance and behavior
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN]  = "󰀪 ",
            [vim.diagnostic.severity.INFO]  = "󰋽 ",
            [vim.diagnostic.severity.HINT]  = "󰌶 ",
          },
        } or {},
        virtual_text = {
          source = "if_many",
          spacing = 2,
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      })

      -- LSP servers via vim.lsp.config / vim.lsp.enable
      local servers = {
        gopls = {
          settings = {
            gopls = {
              directoryFilters = { "-.git", "-node_modules" },
              analyses = { unusedparams = true, shadow = true },
              staticcheck = true,
            },
          },
          flags = { debounce_text_changes = 150 },
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = {
                library = { [vim.fn.stdpath("config") .. "/lua"] = true },
                checkThirdParty = false,
                maxPreload = 100,
                preloadFileSize = 100,
              },
              telemetry = { enable = false },
            },
          },
        },
        pyright = {},
        bashls = {},
      }

      for name, cfg in pairs(servers) do
        vim.lsp.config(name, cfg)
        vim.lsp.enable(name)
      end
    end,
  },
}
