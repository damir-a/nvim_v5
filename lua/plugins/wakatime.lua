return {
  {
    "wakatime/vim-wakatime",
    lazy = false,
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local wakatime_cli = vim.fn.expand "~/.wakatime/wakatime-cli-darwin-arm64"

      -- Today с notification
      vim.api.nvim_create_user_command("WakaTimeTodayFixed", function()
        if vim.fn.executable(wakatime_cli) == 0 then
          vim.notify("WakaTime CLI не найден: " .. wakatime_cli, vim.log.levels.ERROR)
          return
        end

        local result = vim.fn.system(wakatime_cli .. " --today")

        if vim.v.shell_error ~= 0 then
          vim.notify("WakaTime ошибка: " .. result, vim.log.levels.ERROR)
          return
        end

        result = vim.trim(result)
        vim.notify("📊 Сегодня: " .. result, vim.log.levels.INFO)
      end, { desc = "WakaTime today (notification)" })

      -- Today с floating window (красивее)
      vim.api.nvim_create_user_command("WakaTimeTodayPopup", function()
        if vim.fn.executable(wakatime_cli) == 0 then
          vim.notify("WakaTime CLI не найден", vim.log.levels.ERROR)
          return
        end

        local result = vim.fn.system(wakatime_cli .. " --today")

        if vim.v.shell_error ~= 0 then
          vim.notify("WakaTime ошибка: " .. result, vim.log.levels.ERROR)
          return
        end

        result = vim.trim(result)

        -- Создаем буфер
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
          "╭─────────────────────────────╮",
          "│   📊 WakaTime Today         │",
          "╰─────────────────────────────╯",
          "",
          "  " .. result,
          "",
          "  Press q or ESC to close",
        })

        -- Создаем floating window
        local width = 35
        local height = 7
        vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          col = (vim.o.columns - width) / 2,
          row = (vim.o.lines - height) / 2,
          style = "minimal",
          border = "rounded",
        })

        -- Опции буфера
        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

        -- Закрыть по q или ESC
        vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, "n", "<ESC>", ":close<CR>", { noremap = true, silent = true })
      end, { desc = "WakaTime today (popup window)" })

      -- Today без категорий (только total)
      vim.api.nvim_create_user_command("WakaTimeTodayTotal", function()
        if vim.fn.executable(wakatime_cli) == 0 then
          vim.notify("WakaTime CLI не найден", vim.log.levels.ERROR)
          return
        end

        -- --today-hide-categories для чистого времени
        local result = vim.fn.system(wakatime_cli .. " --today --today-hide-categories=true")

        if vim.v.shell_error ~= 0 then
          vim.notify("WakaTime ошибка: " .. result, vim.log.levels.ERROR)
          return
        end

        result = vim.trim(result)
        vim.notify("⏱️ Total: " .. result, vim.log.levels.INFO)
      end, { desc = "WakaTime today total (no categories)" })

      -- Биндинги
      local maps = opts.mappings or {}
      maps.n = maps.n or {}

      maps.n["<Leader>wt"] = {
        "<cmd>WakaTimeTodayFixed<CR>",
        desc = "WakaTime Today (notification)",
      }
      maps.n["<Leader>wp"] = {
        "<cmd>WakaTimeTodayPopup<CR>",
        desc = "WakaTime Today (popup)",
      }
      maps.n["<Leader>wT"] = {
        "<cmd>WakaTimeTodayTotal<CR>",
        desc = "WakaTime Total (no categories)",
      }

      return opts
    end,
  },
}
