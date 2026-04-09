return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        clangd = {},
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "python",
        "cpp",
        "cmake",
        "bash",
        "json",
        "yaml",
      },
    },
  },

  -- ROS2 launch file support
  {
    "nvim-lua/plenary.nvim",
    config = function()
      vim.filetype.add({
        extension = {
          launch = "python",
        },
      })
    end,
  },
}