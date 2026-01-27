return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings

      -- Функция для запуска resterm
      local function resterm_toggle()
        local Terminal = require("toggleterm.terminal").Terminal

        -- Проверяем установлен ли resterm
        if vim.fn.executable "resterm" == 0 then
          vim.notify("resterm не установлен. Установи: cargo install resterm", vim.log.levels.ERROR)
          return
        end

        -- Создаем терминал с resterm (или переиспользуем существующий)
        local resterm = Terminal:new {
          cmd = "resterm",
          hidden = true,
          direction = "float", -- или "horizontal", "vertical", "tab"
          float_opts = {
            border = "curved",
            width = function() return math.floor(vim.o.columns * 0.9) end,
            height = function() return math.floor(vim.o.lines * 0.9) end,
          },
          on_open = function(term)
            vim.cmd "startinsert!"
            -- Disable line numbers in terminal
            vim.api.nvim_set_option_value("number", false, { win = term.window })
            vim.api.nvim_set_option_value("relativenumber", false, { win = term.window })
          end,
          on_close = function() vim.cmd "startinsert!" end,
        }

        resterm:toggle()
      end

      -- Биндинг
      maps.n["<Leader>tr"] = { resterm_toggle, desc = "Toggle Resterm" }

      return opts
    end,
  },
}
