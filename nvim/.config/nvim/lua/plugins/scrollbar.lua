-- lua/plugins/scrollbar.lua
return {
  "petertriho/nvim-scrollbar",
  event = "BufReadPost",
  opts = {
    handlers = {
      diagnostic = true,
    },
  },
}
