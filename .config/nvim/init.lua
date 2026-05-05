vim.opt.runtimepath:prepend(vim.fn.expand("~/.vim"))
vim.opt.runtimepath:append(vim.fn.expand("~/.vim/after"))
vim.o.packpath = vim.o.runtimepath

vim.cmd("source " .. vim.fn.fnameescape(vim.fn.expand("~/.vimrc")))

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("gh-permalink").setup({
  mappings = {
    open = "<leader>gh",
    copy = "<leader>gH",
  },
})

-- Go to definition
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { silent = true })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { silent = true })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { silent = true })
