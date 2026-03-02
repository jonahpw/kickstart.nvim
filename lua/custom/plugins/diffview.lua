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

return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    {
      '<leader>gd',
      function()
        vim.cmd('DiffviewOpen -C' .. project_root() .. ' origin/dev...HEAD')
      end,
      desc = 'Diff against origin/dev',
    },
    {
      '<leader>gh',
      function()
        local file = vim.fn.expand('%:p')
        vim.cmd('DiffviewFileHistory -C' .. project_root() .. ' ' .. file)
      end,
      desc = 'File history',
    },
  },
}
