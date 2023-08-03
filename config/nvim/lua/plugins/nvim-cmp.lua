return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    {"onsails/lspkind-nvim"},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/cmp-buffer'},
    {'hrsh7th/cmp-vsnip'},
    {'hrsh7th/vim-vsnip'},
    {'hrsh7th/cmp-path'},
    {'hrsh7th/cmp-nvim-lua'},
    {'petertriho/cmp-git'},
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
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer" },
        { name = "nvim_lsp_signature_help" },
        -- { name = 'vsnip' }, -- For vsnip users.
        -- { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
      }, {
        { name = 'buffer' },
      }),
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

    -- require("cmp_git").setup()
    -- -- Set configuration for specific filetype.
    -- cmp.setup.filetype('gitcommit', {
      -- sources = cmp.config.sources({
        -- { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
      -- }, {
        -- { name = 'buffer' },
      -- })
    -- })

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })

    -- -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    -- cmp.setup.cmdline(':', {
      -- mapping = cmp.mapping.preset.cmdline(),
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

    -- Add additional capabilities supported by nvim-cmp
    local protocol = vim.lsp.protocol
    local capabilities = require('cmp_nvim_lsp').default_capabilities(
      protocol.make_client_capabilities()
    )
    local completionItem = capabilities.textDocument.completion.completionItem
    completionItem.documentationFormat = { 'markdown', 'plaintext' }
    completionItem.snippetSupport = true
    completionItem.preselectSupport = true
    completionItem.insertReplaceSupport = true
    completionItem.labelDetailsSupport = true
    completionItem.deprecatedSupport = true
    completionItem.commitCharactersSupport = true
    completionItem.tagSupport = { valueSet = { 1 } }
    completionItem.resolveSupport = {
      properties = { 'documentation', 'detail', 'additionalTextEdits' },
    }
  end,
}
