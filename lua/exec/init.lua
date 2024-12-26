local M = {}

-- TODO: add support for compiled languages by adding helpers to create tmpfiles/tmpdirs to compile and run code in

---@alias exec.runner fun(string): string[]

---@class exec.Options
---@field runners { [string]: exec.runner}

-- create runner that executes 'e <file containing code>'
---@nodiscard
---@param e string
---@return exec.runner
M.make_simple_runner = function(e)
  return function(code)
    local tmpfile = vim.fn.tempname()
    vim.fn.writefile(code, tmpfile)
    local output = vim.system({ e, tmpfile }, { text = true }):wait()
    vim.fn.delete(tmpfile)

    return vim.split(output.stdout, '\n')
  end
end

---@nodiscard
---@return string[]
local selected_text = function()
  vim.cmd('normal! \28\14')
  local start = vim.api.nvim_buf_get_mark(0, '<')
  local ending = vim.api.nvim_buf_get_mark(0, '>')
  return vim.api.nvim_buf_get_text(0, start[1] - 1, start[2], ending[1] - 1, ending[2] + 1, {})
end

local state = {
  ---@type { [string]: exec.runner}
  runners = {
    javascript = M.make_simple_runner('node'),
    lua = function(_)
      vim.fn.feedkeys('gv', 'n')
      vim.cmd('\'<,\'>source')
      vim.cmd('normal! \28\14')
      return {}
    end,
    python = M.make_simple_runner('python'),
    sh = M.make_simple_runner('bash'),
  },
}

-- Runs visually selected code and returns collected `stdout` after termination.
-- Returns nil if no runner is configured for current ft.
---@return string[] | nil
M.run_selected = function()
  local runner = state.runners[vim.bo.filetype]
  if runner == nil then
    print('No executor configured for filetype "' .. vim.bo.filetype .. '"!')
    return nil
  end
  local code = selected_text()
  return runner(code)
end

---@param opts exec.Options
M.setup = function(opts)
  vim.tbl_extend('force', state.runners, opts.runners)
end

return M
