return {
    {
        "ray-x/lsp_signature.nvim",
        event = "LspAttach",
        ---@module 'lsp_signature'
        ---@type lsp_signature.Config
        opts = {
            bind = true,
            floating_window = true,
            hint_enable = true,
            hint_prefix = {
                above = "↙ ", -- when the hint is on the line above the current line
                current = "← ", -- when the hint is on the same line
                below = "↖ " -- when the hint is on the line below the current line
            },
            handler_opts = {
                border = "single"
            },
            max_height = 12,
            doc_lines = 0,
        },
        config = function(_, opts)
            require("lsp_signature").setup(opts)
        end,
    },
}
