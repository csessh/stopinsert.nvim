local root = vim.fn.fnamemodify(""..debug.getinfo(1, 'S').source:sub(2).."", ':h:h')
vim.opt.runtimepath:append(root)
local plenary = os.getenv('PLENARY_PATH') or vim.fn.stdpath('data') .. '/site/pack/packer/start/plenary.nvim'
vim.opt.runtimepath:append(plenary)
