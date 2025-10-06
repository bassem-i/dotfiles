return {
  -- Treesitter parser for Bash/shell scripts
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure bash (and optionally fish, etc.) parsers are installed
      vim.list_extend(opts.ensure_installed, { "bash" })
    end,
  },

  -- Mason LSP installer, add bashls
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, { "bashls" })
    end,
  },

  -- Optionally, add formatters and linters (shfmt, shellcheck)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "shellcheck" })
    end,
  },
}
