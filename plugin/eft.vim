if exists('g:loaded_eft')
  finish
endif
let g:loaded_eft = v:true

let g:eft_ignorecase = get(g:, 'eft_ignorecase', v:false)

let g:eft_highlight = get(g:, 'eft_highlight', {
\   '1': {
\     'highlight': 'EftChar',
\     'allow_space': v:true,
\     'allow_operator': v:true,
\   },
\   '2': {
\     'highlight': 'EftSubChar',
\     'allow_space': v:false,
\     'allow_operator': v:false,
\   }
\ })

let g:eft_index_function = get(g:, 'eft_index_function', {
\   'head': function('eft#index#head'),
\   'tail': function('eft#index#tail'),
\   'camel': function('eft#index#camel'),
\   'space': function('eft#index#space'),
\   'symbol': function('eft#index#symbol'),
\ })

if !hlexists('EftChar')
  highlight! default EftChar
  \   gui=bold,underline
  \   guifg=Orange
  \   guibg=NONE
  \   cterm=bold,underline
  \   ctermfg=Red
  \   ctermbg=NONE
endif

if !hlexists('EftSubChar')
  highlight! default EftSubChar
  \   gui=bold,underline
  \   guifg=Gray
  \   guibg=NONE
  \   cterm=bold,underline
  \   ctermfg=Gray
  \   ctermbg=NONE
endif

nnoremap <silent><expr> <Plug>(eft-repeat) eft#repeat()
xnoremap <silent><expr> <Plug>(eft-repeat) eft#repeat()

nnoremap <silent><expr> <Plug>(eft-f) eft#forward(v:false, v:false)
nnoremap <silent><expr> <Plug>(eft-t) eft#forward(v:true, v:false)
xnoremap <silent><expr> <Plug>(eft-f) eft#forward(v:false, v:false)
xnoremap <silent><expr> <Plug>(eft-t) eft#forward(v:true, v:false)
onoremap <silent> <Plug>(eft-f) :<C-u>call eft#forward(v:false, v:false)<CR>
onoremap <silent> <Plug>(eft-t) :<C-u>call eft#forward(v:true, v:false)<CR>

nnoremap <silent><expr> <Plug>(eft-F) eft#backward(v:false, v:false)
nnoremap <silent><expr> <Plug>(eft-T) eft#backward(v:true, v:false)
xnoremap <silent><expr> <Plug>(eft-F) eft#backward(v:false, v:false)
xnoremap <silent><expr> <Plug>(eft-T) eft#backward(v:true, v:false)
onoremap <silent> <Plug>(eft-F) :<C-u>call eft#backward(v:false, v:false)<CR>
onoremap <silent> <Plug>(eft-T) :<C-u>call eft#backward(v:true, v:false)<CR>

nnoremap <silent><expr> <Plug>(eft-f-repeatable) eft#forward(v:false, v:true)
nnoremap <silent><expr> <Plug>(eft-t-repeatable) eft#forward(v:true, v:true)
xnoremap <silent><expr> <Plug>(eft-f-repeatable) eft#forward(v:false, v:true)
xnoremap <silent><expr> <Plug>(eft-t-repeatable) eft#forward(v:true, v:true)
onoremap <silent> <Plug>(eft-f-repeatable) :<C-u>call eft#forward(v:false, v:true)<CR>
onoremap <silent> <Plug>(eft-t-repeatable) :<C-u>call eft#forward(v:true, v:true)<CR>

nnoremap <silent><expr> <Plug>(eft-F-repeatable) eft#backward(v:false, v:true)
nnoremap <silent><expr> <Plug>(eft-T-repeatable) eft#backward(v:true, v:true)
xnoremap <silent><expr> <Plug>(eft-F-repeatable) eft#backward(v:false, v:true)
xnoremap <silent><expr> <Plug>(eft-T-repeatable) eft#backward(v:true, v:true)
onoremap <silent> <Plug>(eft-F-repeatable) :<C-u>call eft#backward(v:false, v:true)<CR>
onoremap <silent> <Plug>(eft-T-repeatable) :<C-u>call eft#backward(v:true, v:true)<CR>

