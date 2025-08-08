-- Bootstrap lazy (the package manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- Load all plugins from the 'plugins' directory
local plugin_path = "~/Workspace/dotfiles/neovim/lua/plugins"
local files = vim.fn.globpath(plugin_path, "*.lua", false, true)
local plugins = {
  -- lua functions that many plugins use
  "nvim-lua/plenary.nvim",
  -- tmux & split window navigation
  "christoomey/vim-tmux-navigator",
}

for _, file in ipairs(files) do
  -- Remove ".lua" extension and convert path to module format
  local modname = vim.fn.fnamemodify(file, ":t:r")
  local plugin = require("plugins." .. modname)
  table.insert(plugins, plugin)
end

require("lazy").setup(plugins, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})
