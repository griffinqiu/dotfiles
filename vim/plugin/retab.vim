map <leader>t4 :%s;^\(\s\+\);\=repeat(' ', len(submatch(0))*2);g<cr>
vmap <leader>t4 :s;^\(\s\+\);\=repeat(' ', len(submatch(0))*2);g<cr>
map <leader>t2 :%s;^\(\s\+\);\=repeat(' ', len(submatch(0))/2);g<cr>
vmap <leader>t2 :s;^\(\s\+\);\=repeat(' ', len(submatch(0))/2);g<cr>
