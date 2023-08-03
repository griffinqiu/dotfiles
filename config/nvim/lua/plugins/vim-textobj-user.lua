return {
  'kana/vim-textobj-user',
  dependencies = {
    { 'fvictorio/vim-textobj-backticks' },       -- a` | i`
    { 'kana/vim-textobj-indent' },               -- ai | ii
    { 'sgur/vim-textobj-parameter' },            -- a, | i,
    { 'whatyouhide/vim-textobj-xmlattr' },       -- ax | ix
    { 'nelstrom/vim-textobj-rubyblock' },        -- ar | ir
    { 'bootleq/vim-textobj-rubysymbol' },        -- a: | i:
    { 'whatyouhide/vim-textobj-erb' },           -- aE | iE
    { 'thinca/vim-textobj-between' },            -- af{char} | if{char}
    { 'griffinqiu/vim-textobj-numeral' },        -- an | in, ad | id
  },
}
