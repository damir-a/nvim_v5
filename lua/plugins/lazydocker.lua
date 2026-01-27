return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings

      local lazydocker_terminal = nil

      local function lazydocker_toggle()
        local Terminal = require("toggleterm.terminal").Terminal

        if vim.fn.executable "lazydocker" == 0 then
          vim.notify(
            "lazydocker не установлен. Установи: brew install lazydocker",
            vim.log.levels.ERROR
          )
          return
        end

        if not lazydocker_terminal then
          lazydocker_terminal = Terminal:new {
            cmd = "lazydocker",
            hidden = true,
            direction = "float",
            float_opts = {
              border = "curved",
              width = function() return math.floor(vim.o.columns * 0.95) end,
              height = function() return math.floor(vim.o.lines * 0.95) end,
            },
            on_open = function(term)
              vim.cmd "startinsert!"
              vim.api.nvim_set_option_value("number", false, { win = term.window })
              vim.api.nvim_set_option_value("relativenumber", false, { win = term.window })
            end,
          }
        end

        lazydocker_terminal:toggle()
      end

      maps.n["<Leader>td"] = { lazydocker_toggle, desc = "Toggle Lazydocker" }

      return opts
    end,
  },
}
