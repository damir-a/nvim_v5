return {
  "mrjones2014/smart-splits.nvim",
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<M-Up>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" }
        maps.n["<M-Down>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" }
        maps.n["<M-b>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" }
        maps.n["<M-f>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" }
      end,
    },
  },
}
