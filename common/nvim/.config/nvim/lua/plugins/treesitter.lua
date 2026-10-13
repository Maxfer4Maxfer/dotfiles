return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- main is an incompatible rewrite (no nvim-treesitter.configs)
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "go",
          "python",
          "bash",
          "json",
          "yaml",
          "markdown",
          "vim",
          "toml",
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  }
}

