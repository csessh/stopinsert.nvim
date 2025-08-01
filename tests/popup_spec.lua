local popup = require('stopinsert.popup')

describe('popup module', function()
   local original_api = {}

   before_each(function()
      -- Mock vim.api functions for testing
      original_api.nvim_create_buf = vim.api.nvim_create_buf
      original_api.nvim_get_current_win = vim.api.nvim_get_current_win
      original_api.nvim_win_get_config = vim.api.nvim_win_get_config
      original_api.nvim_open_win = vim.api.nvim_open_win
      original_api.nvim_buf_set_lines = vim.api.nvim_buf_set_lines
      original_api.nvim_win_set_option = vim.api.nvim_win_set_option
      original_api.nvim_win_is_valid = vim.api.nvim_win_is_valid
      original_api.nvim_win_close = vim.api.nvim_win_close

      -- Set up mocks
      vim.api.nvim_create_buf = function() return 1 end
      vim.api.nvim_get_current_win = function() return 1000 end
      vim.api.nvim_win_get_config = function() 
         return { width = 80, height = 24 } 
      end
      vim.api.nvim_open_win = function() return 2000 end
      vim.api.nvim_buf_set_lines = function() end
      vim.api.nvim_win_set_option = function() end
      vim.api.nvim_win_is_valid = function() return true end
      vim.api.nvim_win_close = function() end
   end)

   after_each(function()
      -- Restore original functions
      for key, func in pairs(original_api) do
         vim.api[key] = func
      end
   end)

   describe('show', function()
      it('creates a buffer for the popup', function()
         local buf_created = false
         vim.api.nvim_create_buf = function(listed, scratch)
            buf_created = true
            assert.is_false(listed)
            assert.is_true(scratch)
            return 1
         end

         popup.show("test message", 1000)
         assert.is_true(buf_created)
      end)

      it('gets current window information', function()
         local current_win_called = false
         local win_config_called = false

         vim.api.nvim_get_current_win = function()
            current_win_called = true
            return 1000
         end

         vim.api.nvim_win_get_config = function(win)
            win_config_called = true
            assert.equals(1000, win)
            return { width = 80, height = 24 }
         end

         popup.show("test", 1000)
         assert.is_true(current_win_called)
         assert.is_true(win_config_called)
      end)

      it('opens window with correct configuration', function()
         local win_opened = false
         local expected_opts = {}

         vim.api.nvim_open_win = function(buf, enter, opts)
            win_opened = true
            expected_opts = opts
            assert.equals(1, buf)
            assert.is_false(enter)
            return 2000
         end

         popup.show("Hello World", 1000)

         assert.is_true(win_opened)
         assert.equals("minimal", expected_opts.style)
         assert.equals("win", expected_opts.relative)
         assert.equals(1000, expected_opts.win)
         assert.equals(11, expected_opts.width) -- Length of "Hello World"
         assert.equals(1, expected_opts.height)
         assert.equals("rounded", expected_opts.border)
         -- Position should be bottom-right: row = 24 - 1 - 2 = 21, col = 80 - 11 - 2 = 67
         assert.equals(21, expected_opts.row)
         assert.equals(67, expected_opts.col)
      end)

      it('sets buffer content correctly', function()
         local buf_lines_set = false
         local buffer_content = {}

         vim.api.nvim_buf_set_lines = function(buf, start_line, end_line, strict_indexing, replacement)
            buf_lines_set = true
            buffer_content = replacement
            assert.equals(1, buf)
            assert.equals(0, start_line)
            assert.equals(-1, end_line)
            assert.is_false(strict_indexing)
         end

         popup.show("Test Message", 1000)

         assert.is_true(buf_lines_set)
         assert.same({ "Test Message" }, buffer_content)
      end)

      it('sets window highlight options', function()
         local highlight_set = false

         vim.api.nvim_win_set_option = function(win, option, value)
            highlight_set = true
            assert.equals(2000, win)
            assert.equals("winhl", option)
            assert.equals("Normal:NormalFloat,FloatBorder:FloatBorder", value)
         end

         popup.show("test", 1000)
         assert.is_true(highlight_set)
      end)

      it('calculates correct dimensions for different message lengths', function()
         local opts_captured = {}

         vim.api.nvim_open_win = function(buf, enter, opts)
            table.insert(opts_captured, { width = opts.width, height = opts.height })
            return 2000
         end

         popup.show("Hi", 1000)
         popup.show("This is a longer message", 1000)
         popup.show("", 1000)

         assert.equals(2, opts_captured[1].width)
         assert.equals(1, opts_captured[1].height)
         assert.equals(25, opts_captured[2].width)
         assert.equals(1, opts_captured[2].height)
         assert.equals(0, opts_captured[3].width)
         assert.equals(1, opts_captured[3].height)
      end)

      it('schedules window closure after timeout', function()
         local defer_fn_called = false
         local timeout_used = 0
         local closure_func = nil

         -- Mock vim.defer_fn
         local original_defer_fn = vim.defer_fn
         vim.defer_fn = function(func, timeout)
            defer_fn_called = true
            timeout_used = timeout
            closure_func = func
         end

         popup.show("test", 3000)

         assert.is_true(defer_fn_called)
         assert.equals(3000, timeout_used)
         assert.is_function(closure_func)

         -- Test the closure function
         local close_called = false
         vim.api.nvim_win_close = function(win, force)
            close_called = true
            assert.equals(2000, win)
            assert.is_true(force)
         end

         closure_func()
         assert.is_true(close_called)

         -- Restore vim.defer_fn
         vim.defer_fn = original_defer_fn
      end)

      it('checks window validity before closing', function()
         local original_defer_fn = vim.defer_fn
         local validity_checked = false
         local close_attempted = false

         vim.defer_fn = function(func, timeout)
            -- Execute the closure function immediately for testing
            func()
         end

         vim.api.nvim_win_is_valid = function(win)
            validity_checked = true
            assert.equals(2000, win)
            return false -- Window is not valid
         end

         vim.api.nvim_win_close = function()
            close_attempted = true
         end

         popup.show("test", 1000)

         assert.is_true(validity_checked)
         assert.is_false(close_attempted) -- Should not attempt to close invalid window

         -- Restore vim.defer_fn
         vim.defer_fn = original_defer_fn
      end)

      it('closes valid windows', function()
         local original_defer_fn = vim.defer_fn
         local close_called = false

         vim.defer_fn = function(func, timeout)
            func() -- Execute immediately for testing
         end

         vim.api.nvim_win_is_valid = function() return true end
         vim.api.nvim_win_close = function(win, force)
            close_called = true
            assert.equals(2000, win)
            assert.is_true(force)
         end

         popup.show("test", 1000)
         assert.is_true(close_called)

         -- Restore vim.defer_fn
         vim.defer_fn = original_defer_fn
      end)
   end)
end)