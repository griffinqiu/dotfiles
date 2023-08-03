return function(use)
  -- LSP goodies
  use {
    "onsails/lspkind-nvim",
    "neovim/nvim-lspconfig",
    "ray-x/lsp_signature.nvim",
    "ldelossa/litee.nvim",
    'williamboman/nvim-lsp-installer',
    config = function()
      -- Litee bindings
      vim.cmd(([[
      autocmd Filetype litee lua vim.api.nvim_set_keymap("n", "<Tab>", ":LTExpand<CR>", {})
      autocmd Filetype litee lua vim.api.nvim_set_keymap("n", "zo", ":LTExpand<CR>", {})
      autocmd Filetype litee lua vim.api.nvim_set_keymap("n", "zc", ":LTCollapse<CR>", {})
      autocmd Filetype litee lua vim.api.nvim_set_keymap("n", "zM", ":LTCollapseAll<CR>", {})
      autocmd Filetype litee lua vim.api.nvim_set_keymap("n", "<CR>", ":LTJump<CR>", {})
      autocmd Filetype litee lua vim.api.nvim_set_keymap("n", "t", ":LTJumpTab<CR>", {})
      autocmd Filetype litee lua vim.api.nvim_set_keymap("n", "v", ":LTJumpVSplit<CR>", {})
      autocmd Filetype litee lua vim.api.nvim_set_keymap("n", "s", ":LTJumpSplit<CR>", {})
      autocmd Filetype litee lua vim.api.nvim_set_keymap("n", "h", ":LTHover<CR>", {})
      autocmd Filetype litee lua vim.api.nvim_set_keymap("n", "q", ":q<CR>", {})
      autocmd Filetype litee lua vim.api.nvim_set_keymap("n", "<", ":vert resize -10<CR>", {})
      autocmd Filetype litee lua vim.api.nvim_set_keymap("n", ">", ":vert resize +10<CR>", {})
      ]]))

    require('litee').setup({
      layout_size = 50,
      icons = "nerd",
      disable_default_keymaps = true,
    })
    end
  }

  -- use {
    -- 'neovim/nvim-lspconfig',
    -- requires = {
      -- 'williamboman/nvim-lsp-installer',
    -- },
    -- config = [[require('lsp')]]
  -- }
  -- vim.api.nvim_command('autocmd BufWritePre *.go lua vim.lsp.buf.formatting()')
  -- vim.api.nvim_command('autocmd BufWritePre *.go lua goimports(1000)')

  -- use('ray-x/lsp_signature.nvim')
  use('stevearc/aerial.nvim')

  -- LSP Cmp
  use {
    "hrsh7th/nvim-cmp",
    requires = {
      {"onsails/lspkind-nvim"},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-vsnip'},
      {'hrsh7th/vim-vsnip'},
      {'hrsh7th/cmp-path'},
      {'hrsh7th/cmp-nvim-lua'},
    },
    config = function()
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      local cmp = require('cmp')
      local lspkind = require('lspkind')
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end
        },
        -- formatting = {
          -- format = lspkind.cmp_format(),
        -- },
        formatting = {
          format = function(entry, vim_item)
            local icon = require('lspkind').presets.default[vim_item.kind]
            vim_item.kind = string.format('%s %s', icon, vim_item.kind)

            vim_item.menu = ({
              buffer = '',
              emoji = '',
              vsnip = '',
              nvim_lsp = '',
              nvim_lua = '',
              path = 'פּ',
              calc = '',
              spell = '暈',
              treesitter = '',
            })[entry.source.name]

            return vim_item
          end,
        },
        experimental = {native_menu = false, ghost_text = false},
        sources = {
          { name = 'buffer' },
          { name = 'path' },
        },
        completion = {
          autocomplete = false, -- disable auto-completion.
          completeopt = 'menu,menuone,noinsert',
        },
        mapping = {
          ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.fn["vsnip#available"]() == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
              feedkey("<Plug>(vsnip-jump-prev)", "")
            end
          end, { "i", "s" }),
          ['<C-k>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
          ["<C-u>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        },
      })
      -- Set configuration for specific filetype.
      -- cmp.setup.filetype('gitcommit', {
        -- sources = cmp.config.sources({
          -- { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
        -- }, {
          -- { name = 'buffer' },
        -- })
      -- })
      -- -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
      -- cmp.setup.cmdline('/', {
        -- sources = {
          -- { name = 'buffer' }
        -- }
      -- })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      -- cmp.setup.cmdline(':', {
        -- sources = cmp.config.sources({
          -- { name = 'path' }
        -- }, {
          -- { name = 'cmdline' }
        -- })
      -- })
      vim.cmd([[
        inoremap <C-x><C-o> <Cmd>lua vimrc.cmp.lsp()<CR>
        inoremap <C-x><C-s> <Cmd>lua vimrc.cmp.snippet()<CR>
      ]])
    end
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    config = "require('telescope-config')",
    requires = {
      {'nvim-lua/popup.nvim'},
      {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-fzf-native.nvim'}
    }
  }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use {'cljoly/telescope-repo.nvim'}
end
