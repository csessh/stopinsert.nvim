local stopinsert = require('stopinsert')

describe('stopinsert init module', function()
   local original_api = {}
   local original_vim = {}

   before_each(function()
      -- Mock vim API functions
      original_api.nvim_create_autocmd = vim.api.nvim_create_autocmd
      original_api.nvim_create_augroup = vim.api.nvim_create_augroup
      original_api.nvim_create_user_command = vim.api.nvim_create_user_command
      original_vim.on_key = vim.on_key
      original_vim.bo = vim.bo
      original_vim.fn = vim.fn

      vim.api.nvim_create_autocmd = function() end
      vim.api.nvim_create_augroup = function() return 1 end
      vim.api.nvim_create_user_command = function() end
      vim.on_key = function() end
      vim.bo = { ft = 'lua' }
      vim.fn = { mode = function() return 'n' end }

      -- Reset plugin state
      stopinsert.enable = true
   end)

   after_each(function()
      -- Restore original functions
      for key, func in pairs(original_api) do
         vim.api[key] = func
      end
      for key, func in pairs(original_vim) do
         vim[key] = func
      end
   end)

   describe('module state', function()
      it('is enabled by default', function()
         assert.is_true(stopinsert.enable)
      end)
   end)

   describe('setup', function()
      it('calls config.set with provided options', function()
         local config = require('stopinsert.config')
         local config_set_called = false
         local passed_opts = nil

         local original_set = config.set
         config.set = function(opts)
            config_set_called = true
            passed_opts = opts
         end

         local test_opts = { idle_time_ms = 3000, show_popup_msg = false }
         stopinsert.setup(test_opts)

         assert.is_true(config_set_called)
         assert.same(test_opts, passed_opts)

         -- Restore original function
         config.set = original_set
      end)

      it('handles nil options', function()
         local config = require('stopinsert.config')
         local config_set_called = false
         local passed_opts = nil

         local original_set = config.set
         config.set = function(opts)
            config_set_called = true
            passed_opts = opts
         end

         stopinsert.setup()

         assert.is_true(config_set_called)
         assert.same({}, passed_opts)

         -- Restore original function
         config.set = original_set
      end)

      it('creates autocmd group', function()
         local augroup_created = false
         local augroup_name = nil

         vim.api.nvim_create_augroup = function(name, opts)
            augroup_created = true
            augroup_name = name
            assert.same({ clear = true }, opts)
            return 1
         end

         stopinsert.setup()

         assert.is_true(augroup_created)
         assert.equals("StopInsertAutoCmd", augroup_name)
      end)

      it('creates InsertEnter autocmd', function()
         local autocmd_created = false
         local autocmd_event = nil
         local autocmd_group = nil

         vim.api.nvim_create_autocmd = function(event, opts)
            autocmd_created = true
            autocmd_event = event
            autocmd_group = opts.group
            assert.is_function(opts.callback)
         end

         stopinsert.setup()

         assert.is_true(autocmd_created)
         assert.equals("InsertEnter", autocmd_event)
         assert.equals(1, autocmd_group)
      end)

      it('sets up vim.on_key callback', function()
         local on_key_setup = false
         local key_callback = nil

         vim.on_key = function(callback)
            on_key_setup = true
            key_callback = callback
         end

         stopinsert.setup()

         assert.is_true(on_key_setup)
         assert.is_function(key_callback)
      end)

      it('creates StopInsertPlug user command', function()
         local command_created = false
         local command_name = nil
         local command_opts = nil

         vim.api.nvim_create_user_command = function(name, callback, opts)
            command_created = true
            command_name = name
            command_opts = opts
            assert.is_function(callback)
         end

         stopinsert.setup()

         assert.is_true(command_created)
         assert.equals("StopInsertPlug", command_name)
         assert.equals(1, command_opts.nargs)
         assert.is_function(command_opts.complete)
      end)

      it('provides correct command completion', function()
         local completion_func = nil

         vim.api.nvim_create_user_command = function(name, callback, opts)
            completion_func = opts.complete
         end

         stopinsert.setup()

         local completions = completion_func()
         local expected = { "enable", "disable", "toggle", "status" }
         assert.same(expected, completions)
      end)
   end)

   describe('InsertEnter autocmd callback', function()
      local autocmd_callback = nil
      local util = require('stopinsert.util')

      before_each(function()
         vim.api.nvim_create_autocmd = function(event, opts)
            if event == "InsertEnter" then
               autocmd_callback = opts.callback
            end
         end

         stopinsert.setup()
      end)

      it('returns early when plugin is disabled', function()
         stopinsert.enable = false
         local util_called = false

         local original_reset = util.reset_timer
         util.reset_timer = function() util_called = true end

         autocmd_callback()

         assert.is_false(util_called)
         util.reset_timer = original_reset
      end)

      it('returns early for disabled filetypes', function()
         stopinsert.enable = true
         vim.bo.ft = 'help'
         local util_called = false

         local original_reset = util.reset_timer
         util.reset_timer = function() util_called = true end

         autocmd_callback()

         assert.is_false(util_called)
         util.reset_timer = original_reset
      end)

      it('calls util.reset_timer for enabled filetypes', function()
         stopinsert.enable = true
         vim.bo.ft = 'lua'
         local util_called = false

         local original_reset = util.reset_timer
         util.reset_timer = function() util_called = true end

         autocmd_callback()

         assert.is_true(util_called)
         util.reset_timer = original_reset
      end)
   end)

   describe('on_key callback', function()
      local key_callback = nil
      local util = require('stopinsert.util')

      before_each(function()
         vim.on_key = function(callback)
            key_callback = callback
         end

         stopinsert.setup()
      end)

      it('returns early when not in insert mode', function()
         vim.fn.mode = function() return 'n' end
         local util_called = false

         local original_reset = util.reset_timer
         util.reset_timer = function() util_called = true end

         key_callback('a', 'a')

         assert.is_false(util_called)
         util.reset_timer = original_reset
      end)

      it('returns early when plugin is disabled', function()
         vim.fn.mode = function() return 'i' end
         stopinsert.enable = false
         local util_called = false

         local original_reset = util.reset_timer
         util.reset_timer = function() util_called = true end

         key_callback('a', 'a')

         assert.is_false(util_called)
         util.reset_timer = original_reset
      end)

      it('returns early for disabled filetypes', function()
         vim.fn.mode = function() return 'i' end
         stopinsert.enable = true
         vim.bo.ft = 'help'
         local util_called = false

         local original_reset = util.reset_timer
         util.reset_timer = function() util_called = true end

         key_callback('a', 'a')

         assert.is_false(util_called)
         util.reset_timer = original_reset
      end)

      it('calls util.reset_timer in insert mode for enabled filetypes', function()
         vim.fn.mode = function() return 'i' end
         stopinsert.enable = true
         vim.bo.ft = 'lua'
         local util_called = false

         local original_reset = util.reset_timer
         util.reset_timer = function() util_called = true end

         key_callback('a', 'a')

         assert.is_true(util_called)
         util.reset_timer = original_reset
      end)
   end)

   describe('user commands', function()
      local user_command_callback = nil

      before_each(function()
         vim.api.nvim_create_user_command = function(name, callback, opts)
            user_command_callback = callback
         end

         stopinsert.setup()
      end)

      it('enables plugin with enable command', function()
         stopinsert.enable = false
         user_command_callback({ args = 'enable' })
         assert.is_true(stopinsert.enable)
      end)

      it('disables plugin with disable command', function()
         stopinsert.enable = true
         user_command_callback({ args = 'disable' })
         assert.is_false(stopinsert.enable)
      end)

      it('toggles plugin state with toggle command', function()
         stopinsert.enable = true
         user_command_callback({ args = 'toggle' })
         assert.is_false(stopinsert.enable)

         user_command_callback({ args = 'toggle' })
         assert.is_true(stopinsert.enable)
      end)

      it('prints status when plugin is active', function()
         stopinsert.enable = true
         local printed_message = nil

         local original_print = print
         print = function(msg) printed_message = msg end

         user_command_callback({ args = 'status' })

         assert.equals("StopInsert is active", printed_message)
         print = original_print
      end)

      it('prints status when plugin is inactive', function()
         stopinsert.enable = false
         local printed_message = nil

         local original_print = print
         print = function(msg) printed_message = msg end

         user_command_callback({ args = 'status' })

         assert.equals("StopInsert is inactive", printed_message)
         print = original_print
      end)

      it('ignores invalid commands', function()
         local original_state = stopinsert.enable
         user_command_callback({ args = 'invalid' })
         assert.equals(original_state, stopinsert.enable)
      end)
   end)
end)