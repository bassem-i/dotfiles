-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local git_utils = require("utils.git")
local buffer_utils = require("utils.buffers")

-- vendored from lazyvim https://github.com/LazyVim/LazyVim/blob/f9dadc11b39fb0b027473caaab2200b35c9f0c8b/lua/lazyvim/config/keymaps.lua
local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

----------------------------------------------------------------------
-- Keymaps
----------------------------------------------------------------------

-- Change and delete into separate registers.
-- Leaves the system register as is.
map({ "n", "v" }, "d", '"dd', { noremap = true, desc = "Delete into register d" })
map({ "n", "v" }, "c", '"cc', { noremap = true, desc = "Change into register c" })

map("n", "<leader>bd", function()
  local file_bufs = buffer_utils.get_file_buffers()

  -- Delete all those buffers
  for _, buf in ipairs(file_bufs) do
    vim.api.nvim_buf_delete(buf, {})
  end

  -- Notification about how many buffers were deleted
  vim.notify(
    ("Deleted %d file buf%s."):format(#file_bufs, #file_bufs == 1 and "fer" or "fers"),
    vim.log.levels.INFO,
    { title = "Buffer Delete" }
  )
end, { desc = "Delete All File Buffers" })

-- Copy file path (git)
map("n", "<leader>sp", function()
  local url = git_utils.get_line_on_remote()
  vim.fn.setreg("+", url)

  vim.notify("Copied to clipboard\n" .. url, vim.log.levels.INFO, { title = "Git URL" })
end, { desc = "Copy Git File Path URL" })
