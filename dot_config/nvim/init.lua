vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.hlsearch = false
vim.o.wrap = true
vim.opt.linebreak = true
vim.opt.cmdheight = 0

vim.opt.wildmenu = true
vim.opt.wildmode = "noselect:lastused,full"
vim.opt.wildoptions = { "pum", "fuzzy" }

vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = { ":", "/", "?" },
  callback = function()
    vim.fn.wildtrigger()
  end,
})

-- Keep normal history navigation with Up/Down
vim.keymap.set("c", "<Up>", function()
  return vim.fn.wildmenumode() == 1 and "<C-e><Up>" or "<Up>"
end, { expr = true })

vim.keymap.set("c", "<Down>", function()
  return vim.fn.wildmenumode() == 1 and "<C-e><Down>" or "<Down>"
end, { expr = true })

require("vim._core.ui2").enable({})

vim.pack.add({
	{ src = "https://github.com/rebelot/kanagawa.nvim" },
	{ src = "https://github.com/3rd/image.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/hrsh7th/cmp-path" },
})

require("kanagawa").setup({ transparent = "true" })
require("mason").setup()
vim.cmd("colorscheme kanagawa")

-- nvim-cmp setup
local cmp = require("cmp")

-- Autocomplete for relative path
cmp.setup({
  mapping = cmp.mapping.preset.insert(),
  sources = cmp.config.sources({
    { name = "path" },
  }),
})

-- Typst settings

-- Typst preview, starts qutebrowser
require("typst-preview").setup({
  open_cmd = [[QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor qutebrowser --loglevel error --target tab "%s"]],

  get_root = function(path_of_main_file)
    return vim.fs.root(path_of_main_file, { ".git", "typst.toml" }) or vim.fn.getcwd()
  end,
})

-- Tinymist config
vim.lsp.config("tinymist", {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { "typst.toml", ".git" },
	settings = {
		formatterMode = "typstyle",
		formatterPrintWidth = 80,
		formatterProseWrap = true,
	},
})
-- Autosuggestions
vim.api.nvim_create_autocmd("LspAttach", { 
	callback = function(ev) 
		vim.o.completeopt = "menuone,noselect,popup"
		vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true }) 
	end 
})
vim.lsp.enable({ "lua_ls", "tinymist" })
-- Autoformatting on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.typ",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})


-- Keybindings
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get)
