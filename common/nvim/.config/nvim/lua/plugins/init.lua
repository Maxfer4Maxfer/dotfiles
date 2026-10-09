return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        char = "│",
        show_start = false,
        show_end = false,
      },
    },
  },

  -- call hierarchy
  -- "ray-x/navigator.lua",
  -- "ray-x/go.nvim",

  "tpope/vim-fugitive",
  "tpope/vim-commentary",
  "tpope/vim-surround",

  -- markdown
  -- "iamcco/markdown-preview.nvim",
  -- "mzlogin/vim-markdown-toc",
  -- "preservim/vim-markdown",

  -- "python-mode/python-mode",

  "chrisbra/csv.vim",
  "dhruvasagar/vim-table-mode",

  "aklt/plantuml-syntax",
  "weirongxu/plantuml-previewer.vim",
}
