local buffer_utils = require("utils.buffers")

local buffers = function()
  local file_buf_count = buffer_utils.get_file_buffers_count()

  -- Open file finder if none or only the current file buffer
  if file_buf_count <= 1 then
    Snacks.picker.files({}) -- or your Snacks file picker, adjust options if needed
  else
    Snacks.picker.buffers({
      current = true, -- show the current buffer in the list
      nofile = false, -- hide `buftype=nofile` buffers
      filter = {
        cwd = true,
        filter = function(item, filter)
          -- Temporarily unset self.opts.filter to prevent recursion
          local original_filter = filter.opts.filter
          filter.opts.filter = nil

          local result = filter:match(item)

          -- Restore self.opts.filter after the call
          filter.opts.filter = original_filter

          return result
        end,
      },
    })
  end
end

local resume = function()
  Snacks.picker.resume()
end

local smart = function()
  Snacks.picker.smart({
    title = "Smart search",
  })
end

local pickers = function()
  Snacks.picker.pickers({
    title = "Snacks pickers",
  })
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        enabled = false,
      },
      picker = {
        sources = {
          files = {
            hidden = true, -- show hidden files
            exclude = { ".git", "node_modules", "vendor" }, -- exclude these folders
          },
        },
      },
      matcher = {
        frecency = true, -- enable frecency sorting
      },
    },
    keys = {
      -- Disable snacks explorer. (Use mini.files instead)
      { "<leader>e", false },
      -- Keymaps for file/buffer pickers
      { "<leader><leader>", buffers, desc = "Find buffers or file picker" },
      { "<leader>fr", resume, desc = "Resume last picker" },
      { "<leader>fs", smart, desc = "Smart search" },
      { "<leader>fp", pickers, desc = "Pickers" },
    },
  },
}
