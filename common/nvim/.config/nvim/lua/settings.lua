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
vim.opt.termguicolors = true
vim.opt.updatetime = 100
vim.opt.swapfile = false
vim.opt.laststatus = 2
vim.opt.undofile = false
vim.o.signcolumn = 'yes'
vim.o.exrc = true
vim.o.secure = true

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

vim.o.scrolloff = 4

-- Folding (nvim-ufo)
vim.opt.foldcolumn = "0"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

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

-- A plain `y` also goes to the system clipboard over OSC 52: through tmux (set-clipboard on) and ssh to iTerm2.
-- Neovim's own OSC 52, not a clipboard tool, so a yank in the dev VM lands on the Mac too.
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Copy yanks to the system clipboard',
    callback = function()
        if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
            require('vim.ui.clipboard.osc52').copy('+')(vim.v.event.regcontents)
        end
    end,
})
