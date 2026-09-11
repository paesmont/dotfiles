if vim.fn.has("win32") == 1 then
  return require("plugins.colorscheme.doom-one")
end

local theme_path = vim.fn.stdpath("state") .. "/omarchy/current/theme/neovim.lua"
return dofile(theme_path)

