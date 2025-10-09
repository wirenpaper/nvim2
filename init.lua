vim.g.mapleader = ' '
vim.g.localleader = ' '

-- vim.cmd.colorscheme('terminal-green')
-- vim.cmd.colorscheme('default')

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
vim.keymap.set('n', '<leader>at', ':bel sp | te<CR>', { silent = true })

vim.keymap.set('t', '<C-;>', '<C-\\><C-n>')

----------------------------------------------------

vim.pack.add {
  -- MARK:vim.pack
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = 'https://github.com/mason-org/mason.nvim' },
	{ src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
	{ src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
}

require('mason').setup()
require('mason-lspconfig').setup()
require('mason-tool-installer').setup({
	ensure_installed = {
    -- MARK:mason.install
		"lua_ls",
		"stylua",
    "basedpyright"
	}
})

vim.lsp.config('lua_ls', {
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			},
			diagnostics = {
				globals = {
					'vim',
					'require'
				},
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

-- After your mason setup

-- Setup keybindings when LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    -- MARK:lsp.bindings
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gl', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  end,
})

-- Setup LSP servers using new API (example: Lua)
vim.lsp.config.lua_ls = {
  cmd = { 'lua-language-server' },
  root_markers = { '.luarc.json', '.luacheckrc', '.stylua.toml' },
  filetypes = { 'lua' },
}

-- Enable the server
vim.lsp.enable('lua_ls')
