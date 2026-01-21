return {
  "numToStr/Comment.nvim",
  enabled = true,
  dependencies = {
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      enabled = true, -- 👈 И это тоже
      opts = {
        enable_autocmd = false,
      },
    },
  },
  opts = function()
    return {
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
    }
  end,
}
