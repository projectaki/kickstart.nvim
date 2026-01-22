local M = {}

-- Mock data for testing
local mock_data = {
  'Mock AI Response:',
  '1. Generated code here',
  '2. Some cool suggestion',
  '3. End of output',
}

-- Variables to track buffer and window
local buf = nil
local win = nil

-- Function to open the floating window with mock data
local function open_ai_window()
  -- If the window is already open, close it first
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    win = nil
  end

  -- Create a new buffer if it doesn't exist, or reuse if it does
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true) -- Unlisted, scratch buffer
  end

  -- Set the mock data in the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, mock_data)

  -- Configure the floating window
  local opts = {
    relative = 'cursor', -- Position relative to cursor
    width = 40, -- Width of the window
    height = #mock_data + 2, -- Height based on content + padding
    row = 1, -- Offset from cursor
    col = 1, -- Offset from cursor
    style = 'minimal', -- Minimal UI (no borders by default)
    border = 'single', -- Add a simple border
  }

  -- Open the window and store its ID
  win = vim.api.nvim_open_win(buf, true, opts)

  -- Set buffer options for better behavior
  vim.api.nvim_buf_set_option(buf, 'modifiable', false) -- Prevent editing
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe') -- Wipe buffer when hidden
end

-- Function to close the floating window (best practice)
local function close_ai_window()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true) -- Force close the window
    win = nil
  end
  -- Buffer will be wiped automatically due to 'bufhidden' = 'wipe'
  -- No need to explicitly delete it unless you want to force it
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
    buf = nil
  end
end

-- Set up the keybinding
vim.keymap.set('n', '<leader>fb', function()
  open_ai_window()
end, { noremap = true, silent = true, desc = 'Open AI mock window' })

-- Optional: Add a keybinding to close the window from within it
vim.api.nvim_create_autocmd('BufEnter', {
  buffer = buf, -- This won't work yet since buf is nil until created; see notes
  callback = function()
    vim.keymap.set('n', 'q', function()
      close_ai_window()
    end, { buffer = buf, noremap = true, silent = true, desc = 'Close AI window' })
  end,
})

-- Expose the module (optional, for requiring elsewhere)
M.open_ai_window = open_ai_window
M.close_ai_window = close_ai_window

return M
