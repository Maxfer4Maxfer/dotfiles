vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = false
vim.o.breakindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ruler = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = false
vim.opt.updatetime = 100
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.laststatus = 2
vim.opt.undofile = false
vim.o.signcolumn = 'yes'
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = {
    tab = '  ',
    trail = '·',
    extends = '⟩',
    precedes = '⟨',
    nbsp = '␣',
}
vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    callback = function()
        vim.opt_local.list = false
    end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = "*",
    callback = function()
        vim.opt_local.list = true
    end,
})

vim.o.scrolloff = 8

vim.api.nvim_set_hl(0, 'TabLineFill', { underline = true })
vim.api.nvim_create_autocmd({ "CursorHold", "TextChanged", "TextChangedI" }, {
    pattern = "*",
    command = "silent! update",
})

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})
