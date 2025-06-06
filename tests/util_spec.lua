local util = require('stopinsert.util')
local config = require('stopinsert.config')

describe('util.is_filetype_disabled', function()
  it('matches neo-tree when configured with neo%-tree* pattern', function()
    assert.is_true(vim.tbl_contains(config.config.disabled_filetypes, 'neo%-tree*'))
    assert.is_true(util.is_filetype_disabled('neo-tree'))
  end)
end)
