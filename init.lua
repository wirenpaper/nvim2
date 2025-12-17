vim.g.mapleader = ','
vim.g.localleader = ','

--vim.opt.laststatus = 0

--vim.opt.termguicolors = false

--vim.cmd("set background=dark")
vim.cmd.colorscheme('dark')

-- Tab Completion Settings
vim.opt.wildignorecase = true -- Makes tab completion for files/buffers case-insensitive
vim.opt.wildmenu = true       -- Shows a menu of matches when tab completing

-- Search Settings
vim.opt.ignorecase = true -- Makes searching case-insensitive
vim.opt.smartcase = true  -- ...unless you type a capital letter. Then it becomes case-sensitive.

-- enables yanking from nvim to clipboard
vim.opt.clipboard = 'unnamedplus'

--- Disables automatic commenting on new lines
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- persists where in file you were
vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = '*',
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 1 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.opt.number = true
vim.wo.relativenumber = true
vim.keymap.set('n', ' at', ':bel sp | te<CR>', { silent = true })

vim.keymap.set('t', '<C-;>', '<C-\\><C-n>')

----------------------------------------------------

vim.pack.add {
  -- MARK:vim.pack
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = 'https://github.com/mason-org/mason.nvim' },
	{ src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
	{ src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
	{ src = 'https://github.com/vim-scripts/dante.vim' },
	{ src = 'https://github.com/rose-pine/neovim' },
	{ src = 'https://github.com/vim-scripts/Relaxed-Green' },
  { src = 'https://github.com/hrsh7th/nvim-cmp' },
	{ src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
	{ src = 'https://github.com/hrsh7th/cmp-buffer' },
	{ src = 'https://github.com/habamax/vim-habamax' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },
  { src = 'https://github.com/EdenEast/nightfox.nvim' },
  { src = 'https://github.com/vim-scripts/a.vim' },
  { src = 'https://github.com/vivien/vim-linux-coding-style' },

  -- DAP
  { src = 'https://github.com/mfussenegger/nvim-dap' },
  { src = 'https://github.com/rcarriga/nvim-dap-ui' },
  { src = 'https://github.com/nvim-neotest/nvim-nio' },


  { src = 'https://github.com/sakhnik/nvim-gdb' },
}

-- Mason setup
require('mason').setup()
require('mason-lspconfig').setup()

-- DAP Configuration for C++
local dap = require('dap')
local dapui = require('dapui')

-- Setup dap-ui
dapui.setup()

-- C++ adapter using cpptools
dap.adapters.cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = vim.fn.stdpath('data') .. '/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
}

-- C++ configuration
dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "cppdbg",
    request = "launch",
    program = function()
      local exec_name = vim.fn.input('Executable name: ', '', 'file')
      return vim.fn.getcwd() .. '/build/linux/x86_64/release/' .. exec_name
    end,
    cwd = '${workspaceFolder}',
    stopAtEntry = false,
  },
}

-- Same config for C
dap.configurations.c = dap.configurations.cpp

-- DAP keybindings
vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F9>', dap.step_over, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F10>', dap.step_into, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F11>', dap.step_out, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })

vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'Toggle DAP UI' })
vim.keymap.set('n', '<leader>de', function() require('dapui').eval() end, { desc = 'Evaluate expression' })


-- Completion setup
local cmp = require('cmp')

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  }),
})

-- Setup LSP servers using new API (example: Lua)
vim.lsp.config.lua_ls = {
  cmd = { 'lua-language-server' },
  root_markers = { '.luarc.json', '.luacheckrc', '.stylua.toml' },
  filetypes = { 'lua' },
}

-- Setup C++ LSP (clangd)
vim.lsp.config.clangd = {
  cmd = { 'clangd' },
  root_markers = { 'compile_commands.json', '.git', 'compile_flags.txt' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
}

-- Enable the server
vim.lsp.enable('lua_ls')
vim.lsp.enable('gleam')
vim.lsp.enable('clangd')

-- Ensure .asm and .s files are recognized as 'asm' filetype
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.asm', '*.s', '*.S' },
  callback = function()
    vim.bo.filetype = 'asm'
  end,
})

-- LSP keybindings
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Find references' })


vim.keymap.set('n', '<leader>hi', function()
  local result = vim.treesitter.get_captures_at_cursor(0)
  print(vim.inspect(result))
  -- Also show the highlight group
  local line = vim.fn.line('.')
  local col = vim.fn.col('.')
  local stack = vim.fn.synstack(line, col)
  for _, id in ipairs(stack) do
    print(vim.fn.synIDattr(id, 'name'))
  end
end, { desc = 'Show highlight group under cursor' })
