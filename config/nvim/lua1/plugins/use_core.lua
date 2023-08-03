return function(use)
  use 'tpope/vim-repeat'
  -- use 'tpope/vim-unimpaired'

  -- let g:surround_no_insert_mappings = 1
  -- imap <C-d> <Plug>Isurround
  -- imap <C-e> <Plug>ISurround
  use 'tpope/vim-surround'
  imap("<C-d>", "<Plug>Isurround", "silent", "buffer")
  imap("<C-e>", "<Plug>ISurround", "silent", "buffer")

  use "folke/which-key.nvim"

  -- MixedCase (crm)
  -- camelCase (crc)
  -- snake_case (crs) or (cr_)
  -- UPPER_CASE (cru)
  -- dash-case (cr-)
  -- dot.case (cr.)
  -- space case (cr<space>)
  -- Title Case (crt)
  use 'tpope/vim-abolish'

  -- kana/vim-textobj-user {{{
  use 'kana/vim-textobj-user'
  use 'fvictorio/vim-textobj-backticks'       -- a` | i`
  use 'kana/vim-textobj-indent'               -- ai | ii
  use 'sgur/vim-textobj-parameter'            -- a, | i,
  use 'whatyouhide/vim-textobj-xmlattr'       -- ax | ix
  use 'nelstrom/vim-textobj-rubyblock'        -- ar | ir
  use 'bootleq/vim-textobj-rubysymbol'        -- a: | i:
  use 'whatyouhide/vim-textobj-erb'           -- aE | iE
  use 'thinca/vim-textobj-between'            -- af{char} | if{char}
  use 'griffinqiu/vim-textobj-numeral'        -- an | in, ad | id
  -- }}}
end
