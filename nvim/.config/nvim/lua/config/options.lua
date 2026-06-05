vim.g.python3_host_prog = "/opt/homebrew/bin/python3"
vim.g.lazyvim_python_lsp = "pyrefly"

-- Prefer .git over LSP for project root, so pickers like <leader>/ and
-- <leader><space> scope to the repo root instead of the LSP workspace
-- (which is often a sub-package containing pyproject.toml).
vim.g.root_spec = { { ".git" }, "lsp", "cwd" }
