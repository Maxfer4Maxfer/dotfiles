return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
  },

  {
    "williamboman/mason-lspconfig.nvim",
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
      -- Mason for installing LSP servers
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "pyright", "lua_ls", "bashls" },
        automatic_installation = false,
      })

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

          -- Signature help in command line (disabled by default)
          vim.api.nvim_create_autocmd("CursorHold", {
            callback = function()
              if true then return end -- flip to false to enable

              local client = vim.lsp.get_clients({ bufnr = 0 })[1]
              if not client or not client.server_capabilities.signatureHelpProvider then
                return
              end

              local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
              vim.lsp.buf_request(0, "textDocument/signatureHelp", params, function(err, result)
                if err or not result or not result.signatures or #result.signatures == 0 then
                  return
                end

                local label = result.signatures[1].label
                local name, args, ret = label:match("^([%w_%.]+)%s*%((.-)%)%s*(.*)")
                if not name then
                  vim.api.nvim_echo({ { " " .. label, "Normal" } }, false, {})
                  return
                end

                local arg_chunks = {}
                for arg in args:gmatch("[^,]+") do
                  local arg_name, arg_type = arg:match("^%s*(.-)%s+(.+)%s*$")
                  if arg_name and arg_type then
                    table.insert(arg_chunks, { arg_name, "Identifier" })
                    table.insert(arg_chunks, { " " .. arg_type, "Type" })
                  else
                    table.insert(arg_chunks, { arg, "Type" })
                  end
                  table.insert(arg_chunks, { ", ", "Normal" })
                end
                if #arg_chunks > 0 then table.remove(arg_chunks) end

                local chunks = { { " " }, { name, "Function" }, { "(", "Delimiter" } }
                vim.list_extend(chunks, arg_chunks)
                table.insert(chunks, { ")", "Delimiter" })
                if ret and ret ~= "" then table.insert(chunks, { " " .. ret, "Return" }) end
                vim.api.nvim_echo(chunks, false, {})
              end)
            end,
          })
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
