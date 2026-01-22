return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings

      -- Обычное форматирование с проверкой
      local function format_with(formatter_name)
        return function()
          local clients = vim.lsp.get_clients { bufnr = 0 }
          local formatter_client = nil

          for _, client in ipairs(clients) do
            if client.name == formatter_name then
              formatter_client = client
              break
            end
          end

          if not formatter_client then
            vim.notify(string.format("LSP '%s' не найден", formatter_name), vim.log.levels.WARN)
            return
          end

          if not formatter_client.server_capabilities.documentFormattingProvider then
            vim.notify(
              string.format("LSP '%s' не поддерживает форматирование", formatter_name),
              vim.log.levels.WARN
            )
            return
          end

          vim.lsp.buf.format {
            name = formatter_name,
            timeout_ms = 5000,
            async = false,
          }

          vim.notify(
            string.format("✅ Отформатировано через %s", formatter_name),
            vim.log.levels.INFO
          )
        end
      end

      -- 👇 МАГИЯ: Временное включение Volar форматирования
      local function format_with_volar_temporary()
        local clients = vim.lsp.get_clients { bufnr = 0 }
        local volar_client = nil

        for _, client in ipairs(clients) do
          if client.name == "volar" then
            volar_client = client
            break
          end
        end

        if not volar_client then
          vim.notify("Volar не найден", vim.log.levels.WARN)
          return
        end

        -- Сохраняем оригинальное состояние
        local original_formatting = volar_client.server_capabilities.documentFormattingProvider
        local original_range_formatting = volar_client.server_capabilities.documentRangeFormattingProvider

        -- 👉 Временно ВКЛЮЧАЕМ форматирование
        volar_client.server_capabilities.documentFormattingProvider = true
        volar_client.server_capabilities.documentRangeFormattingProvider = true

        -- Форматируем
        local success, err = pcall(
          function()
            vim.lsp.buf.format {
              name = "volar",
              timeout_ms = 5000,
              async = false,
            }
          end
        )

        -- 👉 ВЫКЛЮЧАЕМ обратно
        volar_client.server_capabilities.documentFormattingProvider = original_formatting
        volar_client.server_capabilities.documentRangeFormattingProvider = original_range_formatting

        if success then
          vim.notify(
            "✅ Отформатировано через Volar (временно включен)",
            vim.log.levels.INFO
          )
        else
          vim.notify("❌ Ошибка форматирования Volar: " .. tostring(err), vim.log.levels.ERROR)
        end
      end

      -- Prettier напрямую
      local function format_with_prettier()
        local bufnr = vim.api.nvim_get_current_buf()
        local filepath = vim.api.nvim_buf_get_name(bufnr)

        if filepath == "" then
          vim.notify("Файл не сохранен", vim.log.levels.WARN)
          return
        end

        if vim.fn.executable "prettier" == 0 then
          vim.notify("Prettier не установлен", vim.log.levels.ERROR)
          return
        end

        local cmd = string.format("prettier --write %s", vim.fn.shellescape(filepath))
        local result = vim.fn.system(cmd)

        if vim.v.shell_error == 0 then
          vim.cmd "edit!"
          vim.notify("✅ Отформатировано через Prettier", vim.log.levels.INFO)
        else
          vim.notify("❌ Prettier ошибка: " .. result, vim.log.levels.ERROR)
        end
      end

      -- Диагностика
      local function show_formatters()
        local clients = vim.lsp.get_clients { bufnr = 0 }

        if #clients == 0 then
          vim.notify("Нет активных LSP клиентов", vim.log.levels.WARN)
          return
        end

        local info = { "📋 LSP клиенты и форматирование:" }

        for _, client in ipairs(clients) do
          local can_format = client.server_capabilities.documentFormattingProvider
          local status = can_format and "✅" or "❌"
          local reason = can_format and "может форматировать" or "НЕ форматирует"
          table.insert(info, string.format("  %s %s - %s", status, client.name, reason))
        end

        vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
      end

      -- Smart format (БЕЗ Volar в приоритетах)
      local function smart_format()
        local filetype = vim.bo.filetype
        local clients = vim.lsp.get_clients { bufnr = 0 }

        local priority = {
          vue = { "eslint", "none-ls", "vtsls" },
          typescript = { "vtsls", "eslint", "none-ls" },
          javascript = { "vtsls", "eslint", "none-ls" },
          typescriptreact = { "vtsls", "eslint", "none-ls" },
          javascriptreact = { "vtsls", "eslint", "none-ls" },
        }

        local preferred = priority[filetype] or {}

        for _, formatter in ipairs(preferred) do
          for _, client in ipairs(clients) do
            if client.name == formatter and client.server_capabilities.documentFormattingProvider then
              vim.lsp.buf.format { name = formatter, timeout_ms = 5000 }
              vim.notify("✅ Отформатировано через " .. formatter, vim.log.levels.INFO)
              return
            end
          end
        end

        for _, client in ipairs(clients) do
          if client.server_capabilities.documentFormattingProvider then
            vim.lsp.buf.format { name = client.name, timeout_ms = 5000 }
            vim.notify("✅ Отформатировано через " .. client.name, vim.log.levels.INFO)
            return
          end
        end

        vim.notify("❌ Нет доступных форматтеров", vim.log.levels.WARN)
      end

      -- Биндинги
      maps.n["<Leader>F"] = { desc = "󰉼 Formatters" }
      maps.n["<Leader>Fa"] = { smart_format, desc = "Format (auto/smart)" }
      maps.n["<Leader>Fe"] = { format_with "eslint", desc = "Format with ESLint" }
      maps.n["<Leader>Fv"] = { format_with "vtsls", desc = "Format with vtsls" }
      maps.n["<Leader>Fn"] = { format_with "none-ls", desc = "Format with None-ls" }
      maps.n["<Leader>Fp"] = { format_with_prettier, desc = "Format with Prettier" }

      -- 👇 Volar с временным включением!
      maps.n["<Leader>Fl"] = { format_with_volar_temporary, desc = "Format with Volar (temp enable)" }

      maps.n["<Leader>Fs"] = { show_formatters, desc = "Show available formatters" }

      return opts
    end,
  },
}
