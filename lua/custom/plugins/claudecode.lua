return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  opts = {
    terminal = {
      split_side = 'right',
      snacks_win_opts = {
        position = 'bottom',
        height = 0.30,
        relative = 'editor',
      },
    },
    diff_opts = {
      keep_terminal_focus = true,
    },
  },
  keys = {
    { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
    { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
  },
}
