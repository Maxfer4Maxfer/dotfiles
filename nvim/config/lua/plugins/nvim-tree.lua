return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        init = function()
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
        end,
        config = function()
            local api = require("nvim-tree.api")

            require("nvim-tree").setup({
                hijack_netrw = true,
                sync_root_with_cwd = true,
                respect_buf_cwd = true,
                update_focused_file = {
                    enable = false,
                },
                actions = {
                    open_file = {
                        quit_on_open = false, -- we'll handle closing
                        window_picker = {
                            enable = false,
                        },
                    },
                },
            })

            -- <leader>e: sidebar toggle (standard)
            vim.keymap.set("n", "<leader>e", function()
                api.tree.toggle({ current_window = false })
            end, { desc = "Toggle NvimTree sidebar" })
        end,
    }
}
