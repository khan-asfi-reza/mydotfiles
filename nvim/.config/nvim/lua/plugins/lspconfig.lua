-- ~/.config/nvim/lua/plugins/lspconfig.lua
return {
  "neovim/nvim-lspconfig",
  init = function()
    vim.lsp.config("pyrefly", {
      cmd = { "uvx", "pyrefly", "lsp" },
      filetypes = { "python" },
      root_markers = { "pyrefly.toml", "pyproject.toml", ".git" },
    })
    vim.lsp.enable("pyrefly")
  end,
  opts = {
    servers = {
      ruff = {
        capabilities = {
          general = { positionEncodings = { "utf-16" } },
        },
        cmd_env = { RUFF_TRACE = "messages" },
        init_options = {
          settings = { logLevel = "error" },
        },
        keys = {
          { "<leader>co", LazyVim.lsp.action["source.organizeImports"], desc = "Organize Imports" },
          {
            "<leader>cf",
            function()
              vim.lsp.buf.format({ name = "ruff", async = true })
            end,
            desc = "Format Buffer (ruff)",
            ft = "python",
          },
        },
      },
    },
  },
}
