return {
  "Pocco81/auto-save.nvim",
  opts = function()
    local snacks = require("snacks")

    -- Track auto-save state manually
    local auto_save_enabled = true

    -- Add toggle to Snacks UI
    snacks
      .toggle({
        name = "Auto Save",
        get = function()
          return auto_save_enabled
        end,
        set = function(state)
          auto_save_enabled = state
          if state then
            require("auto-save").on()
          else
            require("auto-save").off()
          end
        end,
      })
      :map("<leader>ue")

    return {
      execution_message = {
        message = function()
          return ""
        end,
      },
    }
  end,
}
