return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  config = function()
    require("smart-splits").setup({
      -- Ignored buffer types (only while resizing)
      ignored_buftypes = {
        "nofile",
        "quickfix",
        "prompt",
      },
      -- Ignored filetypes (only while resizing)
      ignored_filetypes = { "NvimTree" },
      -- the default number of lines/columns to resize by at a time
      default_amount = 3,
      -- Desired behavior when your cursor is at an edge and you
      -- are moving towards that same edge:
      -- 'wrap' | 'split' | 'stop' | function(ctx) ... end
      -- NOTE: `at_edge = 'wrap'` is not supported on Kitty terminal
      at_edge = "wrap",
      -- Desired behavior when the current window is floating:
      -- 'previous' | 'mux'
      float_win_behavior = "previous",
      -- when moving cursor between splits left or right,
      -- place the cursor on the same row of the *screen*
      move_cursor_same_row = false,
      -- whether the cursor should follow the buffer when swapping
      cursor_follows_swapped_bufs = false,
      -- ignore these autocmd events while processing resize computations
      ignored_events = {
        "BufEnter",
        "WinEnter",
      },
      -- enable or disable a multiplexer integration automatically
      multiplexer_integration = nil,
      -- disable multiplexer navigation if current multiplexer pane is zoomed
      disable_multiplexer_nav_when_zoomed = true,
      -- Supply a Kitty remote control password if needed
      kitty_password = nil,
      -- In Zellij, move to the next tab if at the edge
      zellij_move_focus_or_tab = false,
      -- default logging level
      log_level = "info",
    })

    local ss = require("smart-splits")
    local opts = { silent = true }

    -- resizing splits
    vim.keymap.set("n", "<A-h>", ss.resize_left, opts)
    vim.keymap.set("n", "<A-j>", ss.resize_down, opts)
    vim.keymap.set("n", "<A-k>", ss.resize_up, opts)
    vim.keymap.set("n", "<A-l>", ss.resize_right, opts)

    -- moving between splits
    vim.keymap.set("n", "<C-h>", ss.move_cursor_left, opts)
    vim.keymap.set("n", "<C-j>", ss.move_cursor_down, opts)
    vim.keymap.set("n", "<C-k>", ss.move_cursor_up, opts)
    vim.keymap.set("n", "<C-l>", ss.move_cursor_right, opts)
    vim.keymap.set("n", "<C-\\>", ss.move_cursor_previous, opts)

    -- swapping buffers between windows
    vim.keymap.set("n", "<leader><leader>h", ss.swap_buf_left, opts)
    vim.keymap.set("n", "<leader><leader>j", ss.swap_buf_down, opts)
    vim.keymap.set("n", "<leader><leader>k", ss.swap_buf_up, opts)
    vim.keymap.set("n", "<leader><leader>l", ss.swap_buf_right, opts)
  end,
}
