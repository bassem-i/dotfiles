return {
  {
    -- https://github.com/zbirenbaum/copilot.lua
    "zbirenbaum/copilot.lua",
    lazy = true,
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        auth_provider_url = os.getenv("COPILOT_AUTH_PROVIDER_URL"),
      })
    end,
  },
}
