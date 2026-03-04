return {
  'folke/snacks.nvim',
  opts = {
    lazygit = {},
  },
  keys = {
    { '<leader>gg', function() require('snacks').lazygit() end, desc = 'Lazygit' },
  },
}
