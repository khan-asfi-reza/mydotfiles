local function find_project_root()
  local markers = { "pyproject.toml", "setup.py", "setup.cfg", ".git" }
  local current = vim.fn.expand("%:p:h")
  while current ~= "/" do
    for _, marker in ipairs(markers) do
      local path = current .. "/" .. marker
      if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
        return current
      end
    end
    current = vim.fn.fnamemodify(current, ":h")
  end
  return vim.fn.getcwd()
end

local function rope_move_symbol()
  vim.cmd("write")

  local symbol = vim.fn.expand("<cword>")
  local source_file = vim.fn.expand("%:p")
  local project_root = find_project_root()
  local script = vim.fn.expand("~/.config/nvim/scripts/rope_move.py")

  vim.ui.input({
    prompt = "Move '" .. symbol .. "' to file: ",
    default = vim.fn.expand("%:p:h") .. "/",
    completion = "file",
  }, function(dest)
    if not dest or dest == "" then
      vim.notify("Move cancelled", vim.log.levels.INFO)
      return
    end

    local cmd = {
      "uv", "run", "--with", "rope",
      "python", script,
      project_root, source_file, symbol, dest,
    }

    vim.notify("Moving '" .. symbol .. "'...", vim.log.levels.INFO)

    vim.system(cmd, { text = true, cwd = project_root }, function(result)
      vim.schedule(function()
        if result.code == 0 then
          vim.notify("Moved '" .. symbol .. "' to " .. dest, vim.log.levels.INFO)
          vim.cmd("checktime")
        else
          vim.notify(
            "Move failed:\n" .. (result.stderr or "") .. (result.stdout or ""),
            vim.log.levels.ERROR
          )
        end
      end)
    end)
  end)
end

return {
  "neovim/nvim-lspconfig",
  keys = {
    { "<leader>cb", rope_move_symbol, desc = "Rope: Move symbol to file", ft = "python" },
  },
}
