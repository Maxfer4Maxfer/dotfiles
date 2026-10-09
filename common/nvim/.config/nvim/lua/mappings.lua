local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- General
keymap("n", "<leader><space>", "<cmd>nohlsearch<CR>", opts)

-- Folding
keymap("n", "zR", function() require("ufo").openAllFolds() end, opts)
keymap("n", "zM", function() require("ufo").closeAllFolds() end, opts)

-- Buffers
keymap("n", "<leader>bn", "<cmd>bnext<CR>", opts)
keymap("n", "<leader>bp", "<cmd>bprevious<CR>", opts)
keymap("n", "<leader>bd", "<cmd>bd<CR>", opts)

-- Formatting
keymap("n", "<leader>fm", function() vim.lsp.buf.format { async = true } end, opts)

-- Scrolls
keymap("n", "<C-l>", "zl", opts)
keymap("n", "<C-h>", "zh", opts)

-- Reload config
keymap("n", "<leader>sv", "<cmd>source $MYVIMRC<CR>", opts)

-- Copy full path
keymap("n", "<leader>cp", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end, opts)
