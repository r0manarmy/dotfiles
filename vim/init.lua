local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- colorscheme
  { 
    'rose-pine/neovim',
    name = 'rose-pine',
    config = function ()
      require("rose-pine").setup({
        variant = "main"
      })
      vim.cmd([[colorscheme rose-pine]])
    end,
  },
  {
    'olimorris/onedarkpro.nvim',
  },

  -- statusline
  { 
    "nvim-lualine/lualine.nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
      require("lualine").setup({
        options = { theme = 'gruvbox' },
        sections = {
          lualine_c = {
            {
              'filename',
              file_status = true, -- displays file status (readonly status, modified status)
              path = 2 -- 0 = just filename, 1 = relative path, 2 = absolute path
            }
          }
        }
      })
    end,
  },

  -- go
  {
    "fatih/vim-go",
    config = function ()
      -- we disable most of these features because treesitter and nvim-lsp
      -- take care of it
      vim.g['go_gopls_enabled'] = 0
      vim.g['go_code_completion_enabled'] = 0
      vim.g['go_fmt_autosave'] = 0
      vim.g['go_imports_autosave'] = 0
      vim.g['go_mod_fmt_autosave'] = 0
      vim.g['go_doc_keywordprg_enabled'] = 0
      vim.g['go_def_mapping_enabled'] = 0
      vim.g['go_textobj_enabled'] = 0
      vim.g['go_list_type'] = 'quickfix'
    end,
  },

  -- search selection via *
  { 'bronson/vim-visual-star-search' },

  -- testing framework
  { 
    "vim-test/vim-test",
    config = function ()
      vim.g['test#strategy'] = 'neovim'
      vim.g['test#neovim#start_normal'] = '1'
      vim.g['test#neovim#term_position'] = 'vert'
    end,
  },

  {
    'dinhhuy258/git.nvim',
    config = function ()
      require("git").setup()
    end,
  },


  -- markdown
  {
    "iamcco/markdown-preview.nvim",
    dependencies = {
      "zhaozg/vim-diagram",
      "aklt/plantuml-syntax",
    },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    ft = "markdown",
    cmd = { "MarkdownPreview" },
  },

  -- commenting out lines
  {
    "numToStr/Comment.nvim",
    config = function()
      require('Comment').setup({
        opleader = {
          ---Block-comment keymap
          block = '<Nop>',
        },
      }) 
    end
  },

  { 
    "AndrewRadev/splitjoin.vim"
  },

  -- fzf extension for telescope with better speed
  {
    "nvim-telescope/telescope-fzf-native.nvim", run = 'make' 
  },

  {'nvim-telescope/telescope-ui-select.nvim' },

  -- fuzzy finder framework
  {
    "nvim-telescope/telescope.nvim", 
    tag = '0.1.4',
    dependencies = { 
      "nvim-lua/plenary.nvim" ,
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function ()
      require("telescope").setup({
        extensions = {
          fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                             -- the default case_mode is "smart_case"
          }
        }
      })

      -- To get fzf loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require('telescope').load_extension('fzf')

      -- To get ui-select loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require("telescope").load_extension("ui-select")
    end,
  },

  -- lsp-config
  {
    "neovim/nvim-lspconfig", 
    config = function ()
      util = require "lspconfig/util"

      local capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      require("lspconfig").gopls.setup({
        capabilities = capabilities,
        flags = { debounce_text_changes = 200 },
        settings = {
          gopls = {
            usePlaceholders = true,
            gofumpt = true,
            analyses = {
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            experimentalPostfixCompletions = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-node_modules" },
            semanticTokens = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })
    end,
  },

  -- Highlight, edit, and navigate code
  { 
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'go',
          'gomod',
          'lua',
          'ruby',
          'vimdoc',
          'vim',
          'bash',
          'fish',
          'markdown',
          'markdown_inline',
          'mermaid',
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<space>", -- maps in normal mode to init the node/scope selection with space
            node_incremental = "<space>", -- increment to the upper named parent
            node_decremental = "<bs>", -- decrement to the previous node
            scope_incremental = "<tab>", -- increment to the upper scope (as defined in locals.scm)
          },
        },
        autopairs = {
          enable = true,
        },
        highlight = {
          enable = true,

          -- Disable slow treesitter highlight for large files
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ["iB"] = "@block.inner",
              ["aB"] = "@block.outer",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']]'] = '@function.outer',
            },
            goto_next_end = {
              [']['] = '@function.outer',
            },
            goto_previous_start = {
              ['[['] = '@function.outer',
            },
            goto_previous_end = {
              ['[]'] = '@function.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>sn'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>sp'] = '@parameter.inner',
            },
          },
        },
      })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function() 
      require("nvim-autopairs").setup {
        check_ts = true,
      }
    end
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function() 
      require("luasnip.loaders.from_vscode").lazy_load()
    end
  },

  -- autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind-nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")

      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      luasnip.config.setup {}

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      require('cmp').setup({
        snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
        },
        formatting = {
          format = lspkind.cmp_format {
            with_text = true,
            menu = {
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              nvim_lua = "[Lua]",
            },
          },
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<CR>'] = cmp.mapping.confirm { select = true },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then 
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        -- don't auto select item
        preselect = cmp.PreselectMode.None,
        window = {
          documentation = cmp.config.window.bordered(),
        },
        view = {
          entries = {
            name = "custom",
            selection_order = "near_cursor",
          },
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Insert,
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = "luasnip", keyword_length = 2},
          { name = "buffer", keyword_length = 5},
        },
      })
    end,
  },
})

----------------
--- SETTINGS ---
----------------

-- disable netrw at the very start of our init.lua, because we use nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true -- Enable 24-bit RGB colors

vim.opt.number = true        -- Show line numbers
vim.opt.showmatch = true     -- Highlight matching parenthesis
vim.opt.splitright = true    -- Split windows right to the current windows
vim.opt.splitbelow = true    -- Split windows below to the current windows
vim.opt.autowrite = true     -- Automatically save before :next, :make etc.

vim.opt.mouse = 'a'                -- Enable mouse support
vim.opt.clipboard = 'unnamedplus'  -- Copy/paste to system clipboard
vim.opt.swapfile = false           -- Don't use swapfile
vim.opt.ignorecase = true          -- Search case insensitive...
vim.opt.smartcase = true           -- ... but not it begins with upper case 
vim.opt.completeopt = 'menuone,noinsert,noselect'  -- Autocomplete options

-- Indent Settings
vim.opt.expandtab = true  -- expand tabs into spaces
vim.opt.shiftwidth = 2    -- number of spaces to use for each step of indent.
vim.opt.tabstop = 2       -- number of spaces a TAB counts for
vim.opt.autoindent = true -- copy indent from current line when starting a new line
vim.opt.wrap = true

vim.g.mapleader = ' '

vim.keymap.set('n', '<Leader>w', ':write!<CR>')       -- fast save
vim.keymap.set('n', '<Leader>l', ':nohlsearch<CR>')   -- clear search highlight

-- Better split switching
vim.keymap.set('', '<C-j>', '<C-W>j')
vim.keymap.set('', '<C-k>', '<C-W>k')
vim.keymap.set('', '<C-h>', '<C-W>h')
vim.keymap.set('', '<C-l>', '<C-W>l')

-- telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<C-b>', builtin.buffers, {})
vim.keymap.set('n', '<C-g>', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>td', builtin.diagnostics, {})
vim.keymap.set('n', '<leader>gs', builtin.grep_string, {})
vim.keymap.set('n', '<leader>gg', builtin.live_grep, {})

-- vim-test
vim.keymap.set('n', '<leader>tt', ':TestNearest -v<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>tf', ':TestFile -v<CR>', { noremap = true, silent = true })

-- Go uses gofmt, which uses tabs for indentation and spaces for aligment.
-- Hence override our indentation rules.
vim.api.nvim_create_autocmd('Filetype', {
  group = vim.api.nvim_create_augroup('setIndent', { clear = true }),
  pattern = { 'go' },
  command = 'setlocal noexpandtab tabstop=4 shiftwidth=4'
})

-- Run gofmt/gofmpt, import packages automatically on save
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('setGoFormatting', { clear = true }),
  pattern = '*.go',
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 2000)
    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, "utf-16")
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
  
    vim.lsp.buf.format()
  end
})

if vim.g.neovide then
  vim.cmd([[colorscheme onelight]])
  vim.g.neovide_cursor_vfx_mode = ""
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_scroll_animation_length = 0
  vim.o.guifont ="CodeNewRoman Nerd Font Mono:h14"

  vim.keymap.set('v', '<C-c>', '"+y') -- Copy
  vim.keymap.set('c', '<C-v>', '<C-R>+') -- Paste command mode
  vim.keymap.set('i', '<C-v>', '<C-R>+') -- Paste insert mode
end
