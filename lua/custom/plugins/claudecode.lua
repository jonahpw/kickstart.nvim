return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  opts = {
    terminal = {
      provider = 'none',
    },
    diff_opts = {
      keep_terminal_focus = false,
    },
  },
  lazy = false,
  keys = {
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
  },
}
