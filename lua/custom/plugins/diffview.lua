return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen origin/dev<CR>', desc = 'Diff against origin/dev' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = 'File history' },
  },
}
