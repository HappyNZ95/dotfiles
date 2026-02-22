local M = {}

function M.setup()
  require("base16-colorscheme").setup({
    -- Background tones
    base00 = "#17120f", -- Default Background
    base01 = "#241f1a", -- Lighter Background (status bars)
    base02 = "#2f2924", -- Selection Background
    base03 = "#9e8e81", -- Comments, Invisibles
    -- Foreground tones
    base04 = "#d5c3b6", -- Dark Foreground (status bars)
    base05 = "#ebe0d9", -- Default Foreground
    base06 = "#ebe0d9", -- Light Foreground
    base07 = "#ebe0d9", -- Lightest Foreground
    -- Accent colors
    base08 = "#ffb4ab", -- Variables, XML Tags, Errors
    base09 = "#c1cc99", -- Integers, Constants
    base0A = "#e2c0a4", -- Classes, Search Background
    base0B = "#ffb874", -- Strings, Diff Inserted
    base0C = "#c1cc99", -- Regex, Escape Chars
    base0D = "#ffb874", -- Functions, Methods
    base0E = "#e2c0a4", -- Keywords, Storage
    base0F = "#93000a", -- Deprecated, Embedded Tags
  })
end

-- Register a signal handler for SIGUSR1 (matugen updates)
local signal = vim.uv.new_signal()
signal:start(
  "sigusr1",
  vim.schedule_wrap(function()
    package.loaded["matugen"] = nil
    require("matugen").setup()
  end)
)

return M
