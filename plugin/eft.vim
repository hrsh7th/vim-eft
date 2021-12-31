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

let g:_eft_mapping = v:false

augroup eft
  autocmd!
  autocmd ColorScheme * call s:highlight()
augroup END

function! s:highlight() abort
  highlight! default EftChar
  \   gui=bold,underline
  \   guifg=Orange
  \   guibg=NONE
  \   cterm=bold,underline
  \   ctermfg=Red
  \   ctermbg=NONE

  highlight! default EftSubChar
  \   gui=bold,underline
  \   guifg=Gray
  \   guibg=NONE
  \   cterm=bold,underline
  \   ctermfg=Gray
  \   ctermbg=NONE
endfunction
call s:highlight()

nnoremap <silent> <Plug>(eft-repeat-next) <Cmd>call eft#repeat(1, ';')<CR>
xnoremap <silent> <Plug>(eft-repeat-next) <Cmd>call eft#repeat(1, ';')<CR>
onoremap <silent> <Plug>(eft-repeat-next) <Cmd>call eft#repeat(1, ';')<CR>
nnoremap <silent> <Plug>(eft-repeat-prev) <Cmd>call eft#repeat(2, ',')<CR>
xnoremap <silent> <Plug>(eft-repeat-prev) <Cmd>call eft#repeat(2, ',')<CR>
onoremap <silent> <Plug>(eft-repeat-prev) <Cmd>call eft#repeat(2, ',')<CR>

nnoremap <expr><silent> <Plug>(eft-f-repeatable) <SID>map('forward', v:false, v:true)
nnoremap <expr><silent> <Plug>(eft-t-repeatable) <SID>map('forward', v:true, v:true)
nnoremap <expr><silent> <Plug>(eft-F-repeatable) <SID>map('backward', v:false, v:true)
nnoremap <expr><silent> <Plug>(eft-T-repeatable) <SID>map('backward', v:true, v:true)

xnoremap <expr><silent> <Plug>(eft-f-repeatable) <SID>map('forward', v:false, v:true)
xnoremap <expr><silent> <Plug>(eft-t-repeatable) <SID>map('forward', v:true, v:true)
xnoremap <expr><silent> <Plug>(eft-F-repeatable) <SID>map('backward', v:false, v:true)
xnoremap <expr><silent> <Plug>(eft-T-repeatable) <SID>map('backward', v:true, v:true)

onoremap <expr><silent> <Plug>(eft-f-repeatable) <SID>map('forward', v:false, v:true)
onoremap <expr><silent> <Plug>(eft-t-repeatable) <SID>map('forward', v:true, v:true)
onoremap <expr><silent> <Plug>(eft-F-repeatable) <SID>map('backward', v:false, v:true)
onoremap <expr><silent> <Plug>(eft-T-repeatable) <SID>map('backward', v:true, v:true)

nnoremap <expr><silent> <Plug>(eft-f) <SID>map('forward', v:false, v:false)
nnoremap <expr><silent> <Plug>(eft-t) <SID>map('forward', v:true, v:false)
nnoremap <expr><silent> <Plug>(eft-F) <SID>map('backward', v:false, v:false)
nnoremap <expr><silent> <Plug>(eft-T) <SID>map('backward', v:true, v:false)

xnoremap <expr><silent> <Plug>(eft-f) <SID>map('forward', v:false, v:false)
xnoremap <expr><silent> <Plug>(eft-t) <SID>map('forward', v:true, v:false)
xnoremap <expr><silent> <Plug>(eft-F) <SID>map('backward', v:false, v:false)
xnoremap <expr><silent> <Plug>(eft-T) <SID>map('backward', v:true, v:false)

onoremap <expr><silent> <Plug>(eft-f) <SID>map('forward', v:false, v:false)
onoremap <expr><silent> <Plug>(eft-t) <SID>map('forward', v:true, v:false)
onoremap <expr><silent> <Plug>(eft-F) <SID>map('backward', v:false, v:false)
onoremap <expr><silent> <Plug>(eft-T) <SID>map('backward', v:true, v:false)

function! s:map(dir, till, repeatable) abort
  let g:_eft_mapping = v:true
  return printf("\<Cmd>call eft#%s({ 'till': %s, 'repeatable': %s })\<CR>",
  \ a:dir,
  \ a:till ? 'v:true' : 'v:false',
  \ a:repeatable ? 'v:true' : 'v:false'
  \ )
endfunction

