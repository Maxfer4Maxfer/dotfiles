return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI for the debugger (scopes, watches, breakpoints, REPL)
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio", -- required by dap-ui

      -- Inline variable values as virtual text
      "theHamsta/nvim-dap-virtual-text",

      -- Install debug adapters through Mason
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",

      -- Language specific helpers
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },

    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Auto-install adapters through Mason. delve (Go) builds out of the box.
      -- debugpy (Python) needs python3-venv on the system; it is installed
      -- on demand below only when present, so a missing venv never errors here.
      require("mason-nvim-dap").setup({
        ensure_installed = { "delve" },
        automatic_installation = true,
        handlers = {}, -- use default adapter configs
      })

      -- UI
      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      -- Open/close the UI automatically with the session
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Breakpoint signs
      local sign = vim.fn.sign_define
      sign("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
      sign("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
      sign("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual", numhl = "" })
      sign("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo", linehl = "", numhl = "" })

      -- Go: debug nearest test, package, etc. (uses delve)
      require("dap-go").setup()

      -- Python: use debugpy installed by Mason, but only if it actually exists.
      -- (Mason needs the system python3-venv package to build it.)
      local mason_debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      if vim.fn.executable(mason_debugpy) == 1 then
        require("dap-python").setup(mason_debugpy)
      end

      -- Keymaps (\ is leader). Prefix \d = debug; F-keys for the hot loop.
      local map = function(keys, fn, desc)
        vim.keymap.set("n", keys, fn, { desc = "DAP: " .. desc, silent = true })
      end

      map("<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
      map("<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, "Conditional breakpoint")
      map("<leader>dl", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end, "Log point")

      map("<leader>dc", dap.continue, "Continue / Start")
      map("<leader>dt", dap.terminate, "Terminate")
      map("<leader>dr", dap.repl.toggle, "Toggle REPL")
      map("<leader>du", dapui.toggle, "Toggle UI")
      map("<leader>de", dapui.eval, "Eval under cursor")

      -- Go-specific: debug the test under the cursor
      map("<leader>dgt", function() require("dap-go").debug_test() end, "Go: debug nearest test")

      -- F-keys: classic debugger stepping (familiar from vimspector / IDEs)
      map("<F5>", dap.continue, "Continue / Start")
      map("<F10>", dap.step_over, "Step over")
      map("<F11>", dap.step_into, "Step into")
      map("<F12>", dap.step_out, "Step out")
    end,
  },
}
