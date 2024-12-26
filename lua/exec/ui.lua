local M = {}

--TODO: make everything customizable:
-- [ ] border
-- [ ] padding
-- [ ] min/max dimensions

---@param content string[]
local open_float = function(content)
  local longest = 0
  for _, line in ipairs(content) do
    if #line > longest then
      longest = #line
    end
  end

  local width = math.min(longest + 5, vim.api.nvim_get_option_value('columns', {}) / 2)
  local height = math.min(#content, vim.api.nvim_get_option_value('lines', {}) / 2)

  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buffer, 0, 0, false, content)

  local float = vim.api.nvim_open_win(buffer, true, {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = width,
    height = height,
    style = 'minimal',
  })

  vim.bo.modifiable = false
  vim.keymap.set('n', '<esc>', function()
    vim.api.nvim_win_close(float, true)
  end, { buffer = buffer })

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(float, true)
  end, { buffer = buffer })
end

-- Runs the currently selected code using `exec.run_selected` and shows results in a floating window.
M.run_float = function()
  local output = require('exec').run_selected()
  if output == nil or #output == 0 then
    return
  end

  open_float(output)
end

return M
