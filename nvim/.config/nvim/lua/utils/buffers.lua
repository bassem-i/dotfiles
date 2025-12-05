local M = {}

--- Get open file buffers
--- @return integer[] file_bufs
function M.get_file_buffers()
  local file_bufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      table.insert(file_bufs, buf)
    end
  end

  return file_bufs
end

--- Count the number of open file buffers
---@return number
function M.get_file_buffers_count()
  local file_buf_count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      file_buf_count = file_buf_count + 1
    end
  end

  return file_buf_count
end

return M
