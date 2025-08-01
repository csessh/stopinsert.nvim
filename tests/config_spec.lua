local config = require('stopinsert.config')

describe('config module', function()
   before_each(function()
      -- Reset config to defaults before each test
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
   end)

   describe('default configuration', function()
      it('has correct default idle_time_ms', function()
         assert.equals(5000, config.config.idle_time_ms)
      end)

      it('has popup message enabled by default', function()
         assert.is_true(config.config.show_popup_msg)
      end)

      it('has correct default clear_popup_ms', function()
         assert.equals(5000, config.config.clear_popup_ms)
      end)

      it('has default disabled filetypes', function()
         assert.is_table(config.config.disabled_filetypes)
         assert.is_true(vim.tbl_contains(config.config.disabled_filetypes, "TelescopePrompt"))
         assert.is_true(vim.tbl_contains(config.config.disabled_filetypes, "help"))
         assert.is_true(vim.tbl_contains(config.config.disabled_filetypes, "neo%-tree*"))
      end)

      it('has no guard function by default', function()
         assert.is_nil(config.config.guard_func)
      end)
   end)

   describe('config.set', function()
      it('updates idle_time_ms', function()
         config.set({ idle_time_ms = 3000 })
         assert.equals(3000, config.config.idle_time_ms)
      end)

      it('updates show_popup_msg', function()
         config.set({ show_popup_msg = false })
         assert.is_false(config.config.show_popup_msg)
      end)

      it('updates clear_popup_ms', function()
         config.set({ clear_popup_ms = 2000 })
         assert.equals(2000, config.config.clear_popup_ms)
      end)

      it('replaces disabled_filetypes list', function()
         local new_filetypes = { "custom", "another" }
         config.set({ disabled_filetypes = new_filetypes })
         assert.same(new_filetypes, config.config.disabled_filetypes)
      end)

      it('sets guard function', function()
         local guard_func = function() return true end
         config.set({ guard_func = guard_func })
         assert.equals(guard_func, config.config.guard_func)
      end)

      it('updates multiple config values at once', function()
         config.set({
            idle_time_ms = 7000,
            show_popup_msg = false,
            disabled_filetypes = { "test" }
         })
         assert.equals(7000, config.config.idle_time_ms)
         assert.is_false(config.config.show_popup_msg)
         assert.same({ "test" }, config.config.disabled_filetypes)
      end)

      it('preserves unmodified config values', function()
         config.set({ idle_time_ms = 8000 })
         assert.equals(8000, config.config.idle_time_ms)
         assert.is_true(config.config.show_popup_msg) -- should remain default
         assert.equals(5000, config.config.clear_popup_ms) -- should remain default
      end)
   end)
end)