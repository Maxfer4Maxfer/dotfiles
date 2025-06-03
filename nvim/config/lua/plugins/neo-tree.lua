return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        init = function()
            vim.g.neo_tree_remove_legacy_commands = 1
        end,
        config = function()
            local neotree = require("neo-tree")

            neotree.setup({
                enable_git_status = true,
                enable_diagnostics = true,

                default_component_configs = {
                    indent = {
                        indent_size = 2,
                        padding = 0,
                        with_expanders = true,
                        expander_highlight = "NeoTreeExpander",
                    },
                    icon = {
                        folder_closed = "",
                        folder_open = "",
                        folder_empty = "",
                        default = "",
                        highlight = "NeoTreeFileIcon",
                    },
                    name = {
                        use_git_status_colors = true,
                        highlight = "NeoTreeFileName",
                    },
                },

                filesystem = {
                    filtered_items = {
                        visible = true, -- show dotfiles
                        hide_dotfiles = false,
                        hide_gitignored = false,
                    },
                    follow_current_file = { enabled = true },
                    hijack_netrw_behavior = "open_default",
                    use_libuv_file_watcher = true,
                },

                event_handlers = {
                    {
                        event = "file_opened",
                        handler = function()
                            require("neo-tree.command").execute({ action = "close" })
                        end,
                    },
                },
            })

            vim.keymap.set("n", "-", function()
                require("neo-tree.command").execute({
                    source = "filesystem",
                    dir = vim.loop.cwd(),
                    position = "current",
                    reveal = true,
                })
            end, { desc = "Open Neo-tree in current split" })
        end,
    }
}
