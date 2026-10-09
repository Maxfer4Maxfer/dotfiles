return {
  "greymd/oscyank.vim",
  lazy = false,
  config = function()
    vim.g.oscyank_term = 'tmux'

    vim.api.nvim_create_autocmd("TextYankPost", {
      callback = function()
        if vim.v.event.operator == "y" and vim.v.event.regname == "" then
          vim.cmd("OscyankRegister")
        end
      end,
    })
  end,
}

