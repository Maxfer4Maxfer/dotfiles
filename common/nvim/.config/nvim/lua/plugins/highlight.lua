return {
  'maxmx03/solarized.nvim',
  lazy = false,
  priority = 1000,
  ---@type solarized.config
  opts = {
    variant = 'winter',   -- "spring" | "summer" | "autumn" | "winter" (default)
    transparent = {
      enabled = true,     -- Master switch to enable transparency
      pmenu = true,       -- Popup menu (e.g., autocomplete suggestions)
      normal = true,      -- Main editor window background
      normalfloat = true, -- Floating windows
      neotree = true,     -- Neo-tree file explorer
      nvimtree = true,    -- Nvim-tree file explorer
      whichkey = true,    -- Which-key popup
      telescope = true,   -- Telescope fuzzy finder
      lazy = true,        -- Lazy plugin manager UI
      mason = true,       -- Mason manage external tooling
    },
    on_colors = function(_, _)
      return {
        base03 = "#0e2a35",
        red = "#ca4238",
        green = "#88982d",
        yellow = "#ae8a2c",
        orange = "#bc5329",
        blue = "#4689cc",
        magenta = "#c24380",
        cyan = "#519e97",
        white = "#ece8d6",
      }
    end,
    on_highlights = function(c, _)
      ---@type solarized.highlights
      return {
        DiagnosticFloatingWarn          = { bg = "NONE" },
        NormalFloat                     = { bg = "NONE" },
        FloatBorder                     = { bg = "NONE" },
        NotificationInfo                = { bg = "NONE" },

        TabLineFill                     = { fg = c.base0, underline = true },
        TabLine                         = { fg = c.base0, underline = true },
        TabLineSel                      = { bg = c.base01, fg = c.base03, underline = true },

        Identifier                      = { fg = c.yellow },
        Parameter                       = { bg = "NONE", fg = c.blue },
        IncSearch                       = { fg = c.base03, bg = c.orange, bold = true },
        LineNr                          = { bg = "NONE" },
        Search                          = { fg = c.base02, bg = c.yellow, bold = true },
        SignColumn                      = { bg = "NONE" },
        SpecialChar                     = { fg = c.orange },

        StatusLine                      = { fg = c.base03, bg = c.base0, bold = false },
        StatusLineNC                    = { fg = c.base03, bg = c.base01, bold = false },

        String                          = { fg = c.cyan, bg = c.base03 },

        vimSet                          = { fg = c.yellow },
        vimOption                       = { fg = c.orange },

        NvimTreeNormal                  = { bg = "NONE" },
        TelescopeNormal                 = { bg = c.base03 },

        -- GitSigns
        GitSignsAdd                     = { bg = c.base03 },
        GitSignsChange                  = { bg = c.base03 },
        GitSignsDelete                  = { bg = c.base03 },

        ["@character.printf"]           = { fg = c.red, bold = false },

        -- neo-tree.nvim
        NeoTreeRootName                 = { fg = c.base0, bg = c.base03 },
        -- nvim.cmp
        CmpDocBorder                    = { fg = c.base03, bg = c.base03 },
        -- nvim.lsp
        LspHoverBorder                  = { fg = c.base03, bg = c.base03 },

        -- bash
        ["@function.call.bash"]         = { fg = c.orange, bg = "NONE" },
        ["@variable.parameter.bash"]    = { fg = c.blue, bg = "NONE" },

        -- json
        ["@property.json"]              = { fg = c.green },
        ["@conceal.json"]               = { fg = c.base0 },

        -- graphql
        ["@variable.parameter.graphql"] = { fg = c.green },
        ["@keyword.graphql"]            = { fg = c.base0 },
        ["@keyword.type.graphql"]       = { fg = c.base0 },

        -- LSP
        ["@function.method.call"]       = { fg = c.base0 },
        ["@punctuation.bracket"]        = { fg = c.base0 },
        ["@variable"]                   = { fg = c.base0 },
        ["@operator"]                   = { fg = c.green },
        ["@keyword"]                    = { fg = c.green },
        ["@module"]                     = { fg = c.base0 },

        -- Lua
        ["@constructor.lua"]            = { fg = c.yellow },
        ["@punctuation.bracket.lua"]    = { fg = c.yellow },
        ["@variable.lua"]               = { fg = c.base0 },
        ["@property.lua"]               = { fg = c.base0 },
        ["@variable.member.lua"]        = { fg = c.base0 },
        ["@variable.parameter.lua"]     = { fg = c.blue, bg = c.base03 },
        ["@lsp.type.parameter.lua"]     = { fg = c.blue, bg = c.base03 },

        ["@lsp.type.variable.lua"]      = { link = "@variable.lua" },
        ["@lsp.type.property.lua"]      = { link = "@property.lua" },

        -- Go
        ["@constant.builtin.go"]        = { fg = c.cyan },
        ["@function.method.call.go"]    = { fg = c.yellow },
        ["@function.call.go"]           = { fg = c.yellow },
        ["@keyword.function.go"]        = { fg = c.green },
        ["@keyword.go"]                 = { fg = c.green },
        ["@keyword.import.go"]          = { fg = c.green },
        ["@module.go"]                  = { fg = c.base0 },
        ["@property.go"]                = { fg = c.blue },
        ["@number.go"]                  = { fg = c.cyan },
        ["@string.go"]                  = { fg = c.cyan },
        ["@type.builtin.go"]            = { fg = c.yellow },
        ["@type.go"]                    = { fg = c.yellow },
        ["@variable.go"]                = { fg = c.base0 },
        ["@variable.parameter.go"]      = { fg = c.blue },
      }
    end,
  },
  config = function(_, opts)
    vim.o.termguicolors = true
    vim.o.background = 'dark'
    require('solarized').setup(opts)
    vim.cmd.colorscheme 'solarized'

    vim.api.nvim_create_user_command("ReloadHighlight", function()
      vim.cmd("Lazy reload solarized.nvim")
    end, {})
  end,
}
