-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

function system_open(path)
  if vim.ui.open then return vim.ui.open(path) end
  local cmd
  if vim.fn.has "win32" == 1 and vim.fn.executable "explorer" == 1 then
    cmd = { "cmd.exe", "/K", "explorer" }
  elseif vim.fn.has "unix" == 1 and vim.fn.executable "xdg-open" == 1 then
    cmd = { "xdg-open" }
  elseif (vim.fn.has "mac" == 1 or vim.fn.has "unix" == 1) and vim.fn.executable "open" == 1 then
    cmd = { "open" }
  end
  vim.fn.jobstart(vim.fn.extend(cmd, { path or vim.fn.expand "<cfile>" }), { detach = true })
end

 local get_icon = require("custom.utils").get_icon
return {
  {
  -- RUST LSP
  "simrat39/rust-tools.nvim",
  dependencies = "neovim/nvim-lspconfig",
  config = function()
    require("rust-tools").setup({
      -- rust-tools options
      tools = {
        autoSetHints = true,
        inlay_hints = {
          show_parameter_hints = true,
          parameter_hints_prefix = "<- ",
          other_hints_prefix = "=> "
        }
      },
      -- all the opts to send to nvim-lspconfig
      -- these override the defaults set by rust-tools.nvim
      --
      -- REFERENCE:
      -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
      -- https://rust-analyzer.github.io/manual.html#configuration
      -- https://rust-analyzer.github.io/manual.html#features
      --
      -- NOTE: The configuration format is `rust-analyzer.<section>.<property>`.
      --       <section> should be an object.
      --       <property> should be a primitive.
      server = {
        on_attach = function(client, bufnr)
          require("shared/lsp")(client, bufnr)
          require("illuminate").on_attach(client)

          local bufopts = {
            noremap = true,
            silent = true,
            buffer = bufnr
          }
          vim.keymap.set('n', '<leader><leader>rr',
            "<Cmd>RustRunnables<CR>", bufopts)
          vim.keymap.set('n', 'K', "<Cmd>RustHoverActions<CR>",
            bufopts)
        end,
        ["rust-analyzer"] = {
          assist = {
            importEnforceGranularity = true,
            importPrefix = "create"
          },
          cargo = { allFeatures = true },
          checkOnSave = {
            -- default: `cargo check`
            command = "clippy",
            allFeatures = true
          }
        },
        inlayHints = {
            auto=true,
            only_current_line = false,
            show_parameter_hints = true,
            highlight = "Comment",
          -- NOT SURE THIS IS VALID/WORKS 😬
          lifetimeElisionHints = {
            enable = true,
            useParameterNames = true
          }
        }
      }
    })
  end
},
  {'rcarriga/nvim-notify',opts = { stages = "fade" }},
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {},
},  {
    "onsails/lspkind.nvim",
    opts = {
      mode = "symbol",
      symbol_map = {
        Array = "󰅪",
        Boolean = "⊨",
        Class = "󰌗",
        Constructor = "",
        Key = "󰌆",
        Namespace = "󰅪",
        Null = "NULL",
        Number = "#",
        Object = "󰀚",
        Package = "󰏗",
        Property = "",
        Reference = "",
        Snippet = "",
        String = "󰀬",
        TypeParameter = "󰊄",
        Unit = "",
      },
      menu = {},
    },
    enabled = vim.g.icons_enabled,
    config = require "custom.plugins.configs.lspkind",
  },
  {
    "folke/todo-comments.nvim",
    dependencies={"nvim-lua/plenary.nvim"},
   
    opts={},
    event = "User AstroFile",
    cmd = {"TodoQuickFix"},
    keys={
      {
        "<leader>T", "<cmd>TodoTelescope<cr>", desc="Open TODOs in Telescope",
    },
  },
  },

 -- {
 --      "m4xshen/hardtime.nvim",
 --     -- opts = }
 --  },
  {
        "kdheepak/lazygit.nvim",
        -- optional for floating window border decoration
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },
{
    "sindrets/diffview.nvim",
    event = "User AstroGitFile",
    cmd = { "DiffviewOpen" },
  },
  {
    "NeogitOrg/neogit",
    optional = true,
    opts = { integrations = { diffview = true } },
  },{
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "User AstroFile",
  opts = { suggestion = { auto_trigger = true, debounce = 150 } },
},
--   {'kevinhwang91/nvim-ufo', dependencies = {'kevinhwang91/promise-async'},
-- opts = {
--   preview = {
--     mappings = {
--       scrollB = "<C-b>", 
--       scrollF = "<C-f>",
--       scrollU = "<C-u>",
--       scrollD = "<C-d>",
--     },
--   },
--   provider_selector = function(_, filetype, buftype)
--     return (filetype == "" or buftype == "nofile") and "indent" -- only use indent until a file is opened
--       or { "treesitter", "indent" } -- if file opened, try to use treesitter if available
--   end,
-- }
--   },
  {
  "nvim-telescope/telescope.nvim",
  dependencies = {
 'nvim-lua/plenary.nvim',

    { "nvim-telescope/telescope-fzf-native.nvim", enabled = vim.fn.executable "make" == 1, build = "make" },
  },
  cmd = "Telescope",

  opts = function()
         local actions = require "telescope.actions"
    return {
      defaults = {
        git_worktrees = vim.g.git_worktrees,
      prompt_prefix = string.format("%s ", get_icon "Search"),
      selection_caret = string.format("%s ", get_icon "Selected"),
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        mappings = {
          i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
          n = { q = actions.close },
        },
      },
    }
  end,
  config = require "custom.plugins.configs.telescope",
},
{
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
opts = {
  auto_clean_after_session_restore = true,
  close_if_last_window = true,
  source_selector = {
    winbar = true,
    content_layout = "center",
    sources = {
      { source = "filesystem", display_name = get_icon "FolderClosed" .. " File" },
      { source = "buffers", display_name = get_icon "DefaultFile" .. " Bufs" },
      { source = "git_status", display_name = get_icon "Git" .. " Git" },
      { source = "diagnostics", display_name = get_icon "Diagnostic" .. " Diagnostic" },
    },
  },
  default_component_configs = {
    indent = { padding = 0, indent_size = 1 },
    icon = {
      folder_closed = get_icon "FolderClosed",
      folder_open = get_icon "FolderOpen",
      folder_empty = get_icon "FolderEmpty",
      default = get_icon "DefaultFile",
    },
    modified = { symbol = get_icon "FileModified" },
    git_status = {
      symbols = {
        added = get_icon "GitAdd",
        deleted = get_icon "GitDelete",
        modified = get_icon "GitChange",
        renamed = get_icon "GitRenamed",
        untracked = get_icon "GitUntracked",
        ignored = get_icon "GitIgnored",
        unstaged = get_icon "GitUnstaged",
        staged = get_icon "GitStaged",
        conflict = get_icon "GitConflict",
      },
    },
  },
  commands = {
    system_open = function(state) system_open(state.tree:get_node():get_id()) end,
    parent_or_close = function(state)
      local node = state.tree:get_node()
      if (node.type == "directory" or node:has_children()) and node:is_expanded() then
        state.commands.toggle_node(state)
      else
        require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
      end
    end,
    child_or_open = function(state)
      local node = state.tree:get_node()
      if node.type == "directory" or node:has_children() then
        if not node:is_expanded() then -- if unexpanded, expand
          state.commands.toggle_node(state)
        else -- if expanded and has children, seleect the next child
          require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
        end
      else -- if not a directory just open it
        state.commands.open(state)
      end
    end,
    copy_selector = function(state)
      local node = state.tree:get_node()
      local filepath = node:get_id()
      local filename = node.name
      local modify = vim.fn.fnamemodify

      local results = {
        e = { val = modify(filename, ":e"), msg = "Extension only" },
        f = { val = filename, msg = "Filename" },
        F = { val = modify(filename, ":r"), msg = "Filename w/o extension" },
        h = { val = modify(filepath, ":~"), msg = "Path relative to Home" },
        p = { val = modify(filepath, ":."), msg = "Path relative to CWD" },
        P = { val = filepath, msg = "Absolute path" },
      }

      local messages = {
        { "\nChoose to copy to clipboard:\n", "Normal" },
      }
      for i, result in pairs(results) do
        if result.val and result.val ~= "" then
          vim.list_extend(messages, {
            { ("%s."):format(i), "Identifier" },
            { (" %s: "):format(result.msg) },
            { result.val, "String" },
            { "\n" },
          })
        end
      end
      vim.api.nvim_echo(messages, false, {})
      local result = results[vim.fn.getcharstr()]
      if result and result.val and result.val ~= "" then
        vim.notify("Copied: " .. result.val)
        vim.fn.setreg("+", result.val)
      end
    end,
  },
  window = {
    width = 30,
    mappings = {
      ["<space>"] = false, -- disable space until we figure out which-key disabling
      ["[b"] = "prev_source",
      ["]b"] = "next_source",
      o = "open",
      O = "system_open",
      h = "parent_or_close",
      l = "child_or_open",
      Y = "copy_selector",
    },
  },
  filesystem = {
    follow_current_file = { enabled = true },
    hijack_netrw_behavior = "open_current",
    use_libuv_file_watcher = true,
  },
  event_handlers = {
    {
      event = "neo_tree_buffer_enter",
      handler = function(_) vim.opt_local.signcolumn = "auto" end,
    },
  },
}
}
 }
