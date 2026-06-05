-- Global patterns always excluded (macOS junk, Python artifacts, etc.)
local GLOBAL_IGNORE = {
  -- Idea file Intellij
  ".idea",
  -- macOS metadata
  ".git",
  ".DS_Store",
  ".AppleDouble",
  ".LSOverride",
  ".DocumentRevisions-V100",
  ".fseventsd",
  ".Spotlight-V100",
  ".TemporaryItems",
  ".Trashes",
  ".VolumeIcon.icns",
  ".com.apple.timemachine.donotpresent",
  ".AppleDB",
  ".AppleDesktop",
  ".apdisk",
  "Icon\r",
  "._*",
  ".venv",
  ".venv*",
  ".virtualenv",
  ".virtualenv",
  -- Python bytecode / caches
  "__pycache__",
  ".ruff_cache",
  ".mypy_cache",
  ".pytest_cache",
  "*.pyc",
  "*.pyo",
  "*.pyd",
  "*$py.class",
  -- Python packaging artifacts
  "*.egg",
  "*.egg-info",
  ".eggs",
  -- C extensions / shared objects
  "*.so",
}


-- Combined pattern list: global + .vimignore
local function all_patterns()
  local combined = {}
  for _, p in ipairs(GLOBAL_IGNORE) do
    table.insert(combined, p)
  end
  return combined
end

-- Convert gitignore-style glob to a Lua pattern
local function glob_to_lua(glob)
  local p = glob:gsub("([%.%+%-%(%)%[%]%^%$%%])", "%%%1")
  p = p:gsub("%*", ".*"):gsub("%?", ".")
  return "^" .. p .. "$"
end

-- Check if a filename matches any pattern
local function matches_any(name, patterns)
  for _, pat in ipairs(patterns) do
    if name == pat then
      return true
    end
    if pat:match("[*?]") and name:match(glob_to_lua(pat)) then
      return true
    end
  end
  return false
end

-- Expand each pattern into recursive globs so snacks' `exclude` matches at any depth,
-- both as a leaf entry (file or empty dir) and as a containing directory.
local function to_globs(patterns)
  local globs = {}
  for _, p in ipairs(patterns) do
    table.insert(globs, "**/" .. p)
    table.insert(globs, "**/" .. p .. "/**")
  end
  return globs
end

-- Module-level cache, refreshed on DirChanged
local current_patterns = all_patterns()
local current_globs = to_globs(current_patterns)

-- Check whether a path (or any of its segments) should be excluded
local function should_exclude(path)
  if not path or path == "" then
    return false
  end
  for segment in path:gmatch("[^/]+") do
    if matches_any(segment, current_patterns) then
      return true
    end
  end
  return false
end

return {
  "snacks.nvim",
  opts = function(_, opts)
    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}

    -- Explorer: use filter function (more reliable than exclude across versions)
    opts.picker.sources.explorer = opts.picker.sources.explorer or {}
    opts.picker.sources.explorer.hidden = true
    opts.picker.sources.explorer.ignored = true
    opts.picker.sources.explorer.exclude = current_globs
    opts.picker.sources.explorer.transform = function(item)
      if item and item.file and should_exclude(item.file) then
        return false
      end
      return item
    end

    -- Files picker: same treatment
    opts.picker.sources.files = opts.picker.sources.files or {}
    opts.picker.sources.files.hidden = true
    opts.picker.sources.files.ignored = true
    opts.picker.sources.files.exclude = current_globs
    opts.picker.sources.files.transform = function(item)
      if item and item.file and should_exclude(item.file) then
        return false
      end
      return item
    end

    -- Reload patterns when cwd changes
    vim.api.nvim_create_autocmd("DirChanged", {
      group = vim.api.nvim_create_augroup("vimignore_reload", { clear = true }),
      callback = function()
        current_patterns = all_patterns()
        current_globs = to_globs(current_patterns)
        local ok, Snacks = pcall(require, "snacks")
        if not ok then
          return
        end
        if Snacks.config.picker and Snacks.config.picker.sources then
          if Snacks.config.picker.sources.explorer then
            Snacks.config.picker.sources.explorer.exclude = current_globs
          end
          if Snacks.config.picker.sources.files then
            Snacks.config.picker.sources.files.exclude = current_globs
          end
        end
      end,
    })

    -- Dashboard (unchanged)
    opts.dashboard = {
      preset = {
        pick = function(cmd, pick_opts)
          return LazyVim.pick(cmd, pick_opts)()
        end,
        header = [[
                                                                       
  ██████   █████                   █████   █████  ███                  
 ░░██████ ░░███                   ░░███   ░░███  ░░░                   
  ░███░███ ░███   ██████   ██████  ░███    ░███  ████  █████████████   
  ░███░░███░███  ███░░███ ███░░███ ░███    ░███ ░░███ ░░███░░███░░███  
  ░███ ░░██████ ░███████ ░███ ░███ ░░███   ███   ░███  ░███ ░███ ░███  
  ░███  ░░█████ ░███░░░  ░███ ░███  ░░░█████░    ░███  ░███ ░███ ░███  
  █████  ░░█████░░██████ ░░██████     ░░███      █████ █████░███ █████ 
 ░░░░░    ░░░░░  ░░░░░░   ░░░░░░       ░░░      ░░░░░ ░░░░░ ░░░ ░░░░░  
                                                                       
]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    }

    return opts
  end,
  keys = {
    {
      "<leader>fh",
      function()
        require("snacks").picker.files({ hidden = true, ignored = true, exclude = {} })
      end,
      desc = "Find Files (show all, bypass ignore)",
    },
  },
}
