return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      vtsls = {
        -- Disable vtsls because tsgo is now being used.
        enabled = false,
      },
    },
  },
}
