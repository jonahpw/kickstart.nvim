local function diffview_safe_close_handler(params)
  local closed_count = 0

  local function is_diffview_tab(win)
    local ok, tabpage = pcall(vim.api.nvim_win_get_tabpage, win)
    if not ok then
      return false
    end
    return vim.t[tabpage].diffview_view_initialized == true
  end

  local function is_diffview_buf(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    return name:match('^diffview://') ~= nil
  end

  -- Phase 1: close diff windows, skipping any in a Diffview tab
  local windows = vim.api.nvim_list_wins()
  local windows_to_close = {}

  for _, win in ipairs(windows) do
    if is_diffview_tab(win) then
      goto continue_win
    end

    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
    local diff_mode = vim.api.nvim_win_get_option(win, 'diff')
    local should_close = false

    if diff_mode then
      should_close = true
    end

    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name:match('%.diff$') or buf_name:match('diff://') then
      should_close = true
    end

    if buftype == 'nofile' and buf_name:match('^fugitive://') then
      should_close = true
    end

    if should_close then
      windows_to_close[win] = true
    end

    ::continue_win::
  end

  for win, _ in pairs(windows_to_close) do
    if vim.api.nvim_win_is_valid(win) then
      local success = pcall(vim.api.nvim_win_close, win, false)
      if success then
        closed_count = closed_count + 1
      end
    end
  end

  -- Phase 2: clean up orphaned diff buffers, skipping Diffview buffers
  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(buf) and not is_diffview_buf(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')

      if
        buf_name:match('%.diff$')
        or buf_name:match('diff://')
        or (buftype == 'nofile' and buf_name:match('^fugitive://'))
      then
        local buf_windows = vim.fn.win_findbuf(buf)
        if #buf_windows == 0 then
          local success = pcall(vim.api.nvim_buf_delete, buf, { force = true })
          if success then
            closed_count = closed_count + 1
          end
        end
      end
    end
  end

  return {
    content = {
      {
        type = 'text',
        text = 'CLOSED_' .. closed_count .. '_DIFF_TABS',
      },
    },
  }
end

return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  opts = {
    terminal = {
      provider = 'none',
    },
    diff_opts = {
      open_in_new_tab = true,
      keep_terminal_focus = false,
    },
  },
  lazy = false,
  keys = {
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
  },
  config = function(_, opts)
    -- Wrap tools.setup so the patch applies whenever tools are registered
    -- (server start may happen later than plugin setup).
    -- The server requires tools as 'claudecode.tools.init' (not 'claudecode.tools').
    -- Lua caches these under different keys, so we must match the exact path.
    local tools = require('claudecode.tools.init')
    local orig_setup = tools.setup
    tools.setup = function(server)
      orig_setup(server)
      if tools.tools['closeAllDiffTabs'] then
        tools.tools['closeAllDiffTabs'].handler = diffview_safe_close_handler
      end
    end

    require('claudecode').setup(opts)
  end,
}
