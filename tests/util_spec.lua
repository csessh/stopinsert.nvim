local util = require('stopinsert.util')
local config = require('stopinsert.config')

describe('util module', function()
   before_each(function()
      -- Reset config to defaults and stop any existing timers
      config.config = {
         idle_time_ms = 5000,
         show_popup_msg = true,
         clear_popup_ms = 5000,
         disabled_filetypes = {
            "TelescopePrompt",
            "checkhealth",
            "help",
            "lspinfo",
            "mason",
            "neo%-tree*",
         },
         guard_func = nil,
      }
      -- Clear any existing timer
      util.reset_timer()
   end)

   describe('is_filetype_disabled', function()
      it('matches neo-tree when configured with neo%-tree* pattern', function()
         assert.is_true(vim.tbl_contains(config.config.disabled_filetypes, 'neo%-tree*'))
         assert.is_true(util.is_filetype_disabled('neo-tree'))
      end)

      it('matches exact filetype names', function()
         assert.is_true(util.is_filetype_disabled('TelescopePrompt'))
         assert.is_true(util.is_filetype_disabled('help'))
         assert.is_true(util.is_filetype_disabled('checkhealth'))
         assert.is_true(util.is_filetype_disabled('lspinfo'))
         assert.is_true(util.is_filetype_disabled('mason'))
      end)

      it('matches pattern-based filetypes', function()
         assert.is_true(util.is_filetype_disabled('neo-tree'))
         assert.is_true(util.is_filetype_disabled('neo-tree-popup'))
         assert.is_true(util.is_filetype_disabled('neo-tree-git'))
      end)

      it('returns false for non-disabled filetypes', function()
         assert.is_false(util.is_filetype_disabled('lua'))
         assert.is_false(util.is_filetype_disabled('python'))
         assert.is_false(util.is_filetype_disabled('javascript'))
         assert.is_false(util.is_filetype_disabled(''))
      end)

      it('handles empty disabled_filetypes list', function()
         config.config.disabled_filetypes = {}
         assert.is_false(util.is_filetype_disabled('help'))
         assert.is_false(util.is_filetype_disabled('neo-tree'))
      end)

      it('handles custom patterns', function()
         config.config.disabled_filetypes = { "test%-.*", "custom" }
         assert.is_true(util.is_filetype_disabled('test-file'))
         assert.is_true(util.is_filetype_disabled('test-spec'))
         assert.is_true(util.is_filetype_disabled('custom'))
         assert.is_false(util.is_filetype_disabled('test'))
         assert.is_false(util.is_filetype_disabled('other'))
      end)
   end)

   describe('timer functionality', function()
      it('creates a timer when reset_timer is called', function()
         -- This test verifies the timer is created without side effects
         util.reset_timer()
         -- Timer creation doesn't have direct observable effects in tests,
         -- but we can verify no errors are thrown
         assert.is_true(true)
      end)

      it('stops existing timer when reset_timer is called multiple times', function()
         util.reset_timer()
         util.reset_timer()
         util.reset_timer()
         -- Multiple calls should not cause errors
         assert.is_true(true)
      end)
   end)

   describe('force_exit_insert_mode', function()
      local original_mode, original_cmd

      before_each(function()
         -- Mock vim functions for testing
         original_mode = vim.fn.mode
         original_cmd = vim.cmd
         vim.fn.mode = function() return 'i' end -- Mock insert mode
         vim.cmd = function() end -- Mock command execution
      end)

      after_each(function()
         -- Restore original functions
         vim.fn.mode = original_mode
         vim.cmd = original_cmd
      end)

      it('exits insert mode when in insert mode', function()
         local cmd_called = false
         vim.cmd = function(command)
            if command == 'stopinsert' then
               cmd_called = true
            end
         end

         util.force_exit_insert_mode()
         assert.is_true(cmd_called)
      end)

      it('does not exit when not in insert mode', function()
         vim.fn.mode = function() return 'n' end -- Normal mode
         local cmd_called = false
         vim.cmd = function() cmd_called = true end

         util.force_exit_insert_mode()
         assert.is_false(cmd_called)
      end)

      it('respects guard function when provided', function()
         config.config.guard_func = function() return true end -- Prevent exit
         local cmd_called = false
         vim.cmd = function() cmd_called = true end

         util.force_exit_insert_mode()
         assert.is_false(cmd_called)
      end)

      it('exits when guard function returns false', function()
         config.config.guard_func = function() return false end -- Allow exit
         local cmd_called = false
         vim.cmd = function(command)
            if command == 'stopinsert' then
               cmd_called = true
            end
         end

         util.force_exit_insert_mode()
         assert.is_true(cmd_called)
      end)

      it('exits when guard function is nil', function()
         config.config.guard_func = nil
         local cmd_called = false
         vim.cmd = function(command)
            if command == 'stopinsert' then
               cmd_called = true
            end
         end

         util.force_exit_insert_mode()
         assert.is_true(cmd_called)
      end)
   end)
end)
