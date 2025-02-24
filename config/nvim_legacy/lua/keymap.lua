nnoremap('k', 'gk')
nnoremap('gk', 'k')
nnoremap('j', 'gj')
nnoremap('gj', 'j')
nnoremap('B', '^')
nnoremap('E', '$')

-- highlight last inserted text
nnoremap('gV', '`[v`]')

-- Copy filename to clipboard
nmap(',cn', ":let @*=expand('%'). ':' . line('.')<CR>")
nmap(',cs', ':let @*=expand("%")<CR>')
nmap(',cf', ':let @*=expand("%:t")<CR>')
nmap(',cl', ':let @*=expand("%:p")<CR>')

-- Move to prev/next buffer
nnoremap('[l', ':lprevious<CR>')
nnoremap(']l', ':lnext<CR>')
nnoremap('[t', ':tabprevious<CR>')
nnoremap(']t', ':tabnext<CR>')
nnoremap('[c', ':cprevious<CR>')
nnoremap(']c', ':cnext<CR>')

noremap('<C-s>', ':update!<CR>', 'silent')
vnoremap('<C-s>', '<C-c>:update!<CR>', 'silent')
inoremap('<C-s>', '<C-o>:update!<CR>', 'silent')

nnoremap('n', 'nzzzv')
nnoremap('N', 'Nzzzv')

nnoremap('g;', 'g;zz')
nnoremap('g,', 'g,zz')

-- nmap('<leader><c-g>', '<c-g>')
-- nmap('<leader><c-l>', '<c-l>')

nnoremap('t<C-]>', ':tabnew %<CR>g<C-]>')
nnoremap('<leader>ct', ':silent ! ctags -R --languages=ruby --exclude=.git --exclude=log -f tags<cr>')

noremap('<right>', 'gt')
noremap('<left>', ' gT')
noremap('<up>', ':lprevious<CR>')
noremap('<down>', ' :lnext<CR>')

imap('<C-]>', '<C-x><C-]>')

map('<leader>co', ':botright copen<cr>')

map('<leader>cd', ':cd %:p:h<cr>')
map('<leader><cr>', ':nohlsearch<cr>', 'silent')

-- Spell
map('<leader>ss', ':setlocal spell!<cr>')
map('<leader>sn', ']s')
map('<leader>sp', '[s')
map('<leader>sa', 'zg')
map('<leader>s?', 'z=')

-- Remove the Windows ^M - when the encodings gets messed up
noremap('<leader><leader>m', "mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm")


local map = vim.keymap.set
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

