-- Grep search on root directory instead of cwd
vim.keymap.set("n", "<leader>/", function()
  Snacks.picker.grep({ root = LazyVim.root() })
end, { desc = "Grep (root)" })
-- Terminal on current directory
vim.keymap.set("n", "<leader>fT", function()
  Snacks.terminal()
end, { desc = "Terminal" })
-- Terminal on root directory
vim.keymap.set("n", "<leader>ft", function()
  Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })

-- Toggle pyrefly
vim.keymap.set("n", "<leader>=", function()
  local clients = vim.lsp.get_clients({ name = "pyrefly" })
  if #clients > 0 then
    vim.lsp.stop_client(clients)
    vim.notify("pyrefly stopped")
  else
    vim.cmd("LspStart pyrefly")
    vim.notify("pyrefly started")
  end
end, { desc = "Toggle pyrefly" })


vim.keymap.del("n", "<leader>K")  -- Keywordprg
vim.keymap.del("n", "<leader>L")  -- LazyVim Changelog
-- Alt+hjkl for LazyVim window navigation
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Go to right window" })
