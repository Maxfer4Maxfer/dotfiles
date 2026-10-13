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

-- Reload config
keymap("n", "<leader>sv", "<cmd>source $MYVIMRC<CR>", opts)

-- Copy full path
keymap("n", "<leader>cp", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end, opts)
