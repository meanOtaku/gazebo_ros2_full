return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
        clangd = {},
        bashls = {},
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