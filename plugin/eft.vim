if exists('g:loaded_eft')
  finish
endif
let g:loaded_eft = v:true

let g:eft_highlight = get(g:, 'eft_highlight', v:false)
let g:eft_ignorecase = get(g:, 'eft_ignorecase', v:false)
let g:eft_index_function = get(g:, 'eft_index_function', {
\   'head': function('eft#index#head'),
\   'tail': function('eft#index#tail'),
\   'camel': function('eft#index#camel'),
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

nnoremap <silent> <Plug>(eft-repeat) :<C-u>call eft#repeat()<CR>
xnoremap <silent> <Plug>(eft-repeat) :<C-u>call eft#repeat()<CR>

nnoremap <silent> <Plug>(eft-f) :<C-u>call eft#forward(v:false, v:false)<CR>
nnoremap <silent> <Plug>(eft-t) :<C-u>call eft#forward(v:true, v:false)<CR>
xnoremap <silent> <Plug>(eft-f) :<C-u>call eft#forward(v:false, v:false)<CR>
xnoremap <silent> <Plug>(eft-t) :<C-u>call eft#forward(v:true, v:false)<CR>
onoremap <silent> <Plug>(eft-f) :<C-u>call eft#forward(v:false, v:false)<CR>
onoremap <silent> <Plug>(eft-t) :<C-u>call eft#forward(v:true, v:false)<CR>

nnoremap <silent> <Plug>(eft-F) :<C-u>call eft#backward(v:false, v:false)<CR>
nnoremap <silent> <Plug>(eft-T) :<C-u>call eft#backward(v:true, v:false)<CR>
xnoremap <silent> <Plug>(eft-F) :<C-u>call eft#backward(v:false, v:false)<CR>
xnoremap <silent> <Plug>(eft-T) :<C-u>call eft#backward(v:true, v:false)<CR>
onoremap <silent> <Plug>(eft-F) :<C-u>call eft#backward(v:false, v:false)<CR>
onoremap <silent> <Plug>(eft-T) :<C-u>call eft#backward(v:true, v:false)<CR>

nnoremap <silent> <Plug>(eft-f-repeatable) :<C-u>call eft#forward(v:false, v:true)<CR>
nnoremap <silent> <Plug>(eft-t-repeatable) :<C-u>call eft#forward(v:true, v:true)<CR>
xnoremap <silent> <Plug>(eft-f-repeatable) :<C-u>call eft#forward(v:false, v:true)<CR>
xnoremap <silent> <Plug>(eft-t-repeatable) :<C-u>call eft#forward(v:true, v:true)<CR>
onoremap <silent> <Plug>(eft-f-repeatable) :<C-u>call eft#forward(v:false, v:true)<CR>
onoremap <silent> <Plug>(eft-t-repeatable) :<C-u>call eft#forward(v:true, v:true)<CR>

nnoremap <silent> <Plug>(eft-F-repeatable) :<C-u>call eft#backward(v:false, v:true)<CR>
nnoremap <silent> <Plug>(eft-T-repeatable) :<C-u>call eft#backward(v:true, v:true)<CR>
xnoremap <silent> <Plug>(eft-F-repeatable) :<C-u>call eft#backward(v:false, v:true)<CR>
xnoremap <silent> <Plug>(eft-T-repeatable) :<C-u>call eft#backward(v:true, v:true)<CR>
onoremap <silent> <Plug>(eft-F-repeatable) :<C-u>call eft#backward(v:false, v:true)<CR>
onoremap <silent> <Plug>(eft-T-repeatable) :<C-u>call eft#backward(v:true, v:true)<CR>

