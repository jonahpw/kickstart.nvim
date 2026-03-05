-- Find the git toplevel for a path (walks up to find .git that is NOT inside a gitignored dir)
local function project_root()
  -- Use the main working directory, not the buffer's nearest .git
  local cwd = vim.fn.getcwd()
  local toplevel = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(cwd) .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error == 0 and toplevel then
    return toplevel
  end
  return cwd
end

local function open_diff(cmd, label)
  local lib = require('diffview.lib')
  local view = lib.get_current_view()
  if view then
    vim.cmd('DiffviewClose')
  else
    vim.cmd(cmd)
    vim.api.nvim_tabpage_set_var(0, 'diff_label', label)
  end
end

return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    {
      '<leader>gd',
      function() open_diff('DiffviewOpen -C' .. project_root() .. ' origin/dev...HEAD', 'diff with origin/dev') end,
      desc = 'Toggle diff against origin/dev',
    },
    {
      '<leader>gc',
      function() open_diff('DiffviewOpen -C' .. project_root(), 'diff uncommitted changes') end,
      desc = 'Toggle uncommitted changes diff',
    },
    {
      '<leader>gh',
      function()
        local file = vim.fn.expand('%:p')
        vim.cmd('DiffviewFileHistory -C' .. project_root() .. ' ' .. file)
        vim.api.nvim_tabpage_set_var(0, 'diff_label', 'file history')
      end,
      desc = 'File history',
    },
  },
}
