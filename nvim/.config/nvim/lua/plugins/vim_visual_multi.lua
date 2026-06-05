-- ~/.config/nvim/lua/plugins/multi-cursor.lua
return {
  "mg979/vim-visual-multi",
  branch = "master",
  init = function()
    vim.g.VM_maps = {
      ["Add Cursor Down"] = "<leader>mj",
      ["Add Cursor Up"]   = "<leader>mk",
      ["Switch Mode"] = "<leader>mt"
    }
  end,
}
