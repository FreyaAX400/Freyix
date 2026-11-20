-- #DEFAULT NVIM OPTIONS# --
vim.opt.number = true
vim.opt.background = "dark"
vim.opt.termguicolors = true
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
-- #BEGIN LAZY NVIM AND PLUGINS# --
-- ========================================================================== --
-- 1. LAZY.NVIM BOOTSTRAP (The Package Manager)                              --
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
--  PLUGIN DEFINITIONS & CONFIGURATION                                      --
-- ========================================================================== --
require("lazy").setup({
  -- ayu theme plugin
  {
    "Shatur/neovim-ayu",
    lazy = false,    
    priority = 1000, 
    config = function()
      require("ayu").setup({
        mirage = false,
      })
      vim.cmd("colorscheme ayu-dark")
    end,
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- Modern Treesitter configuration bypasses the old configs module entirely
      require("nvim-treesitter").setup({
        ensure_installed = { "lua", "bash", "markdown" }, 
        highlight = { enable = true }, -- Note: 'enable', not 'enabled'
      })
    end,
  },

  -- telescope
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
  end,
},

  -- lualine
{
  "nvim-lualine/lualine.nvim",
  config = function()
    require("lualine").setup({
      options = {
        theme = "ayu_dark",
        icons_enabled = true,
      }
    })
  end,
},

  -- mini utils
{
  "echasnovski/mini.nvim",
  version = false,
  config = function()
    require("mini.pairs").setup()   -- Auto-close brackets () [] {} "" ''
    require("mini.comment").setup() -- Toggle comments cleanly with gc
  end,
},
})


