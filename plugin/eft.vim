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

nnoremap <silent> <Plug>(eft-repeat) :<C-u>call eft#repeat()<CR>
xnoremap <silent> <Plug>(eft-repeat) :<C-u>call eft#repeat()<CR>

nnoremap <silent><expr> <Plug>(eft-f) <SID>map('forward', v:false, v:false)
nnoremap <silent><expr> <Plug>(eft-t) <SID>map('forward', v:true, v:false)
xnoremap <silent><expr> <Plug>(eft-f) <SID>map('forward', v:false, v:false)
xnoremap <silent><expr> <Plug>(eft-t) <SID>map('forward', v:true, v:false)
onoremap <silent><expr> <Plug>(eft-f) <SID>map('forward', v:false, v:false)
onoremap <silent><expr> <Plug>(eft-t) <SID>map('forward', v:true, v:false)

nnoremap <silent><expr> <Plug>(eft-F) <SID>map('backward', v:false, v:false)
nnoremap <silent><expr> <Plug>(eft-T) <SID>map('backward', v:true, v:false)
xnoremap <silent><expr> <Plug>(eft-F) <SID>map('backward', v:false, v:false)
xnoremap <silent><expr> <Plug>(eft-T) <SID>map('backward', v:true, v:false)
onoremap <silent><expr> <Plug>(eft-F) <SID>map('backward', v:false, v:false)
onoremap <silent><expr> <Plug>(eft-T) <SID>map('backward', v:true, v:false)

nnoremap <silent><expr> <Plug>(eft-f-repeatable) <SID>map('forward', v:false, v:true)
nnoremap <silent><expr> <Plug>(eft-t-repeatable) <SID>map('forward', v:true, v:true)
xnoremap <silent><expr> <Plug>(eft-f-repeatable) <SID>map('forward', v:false, v:true)
xnoremap <silent><expr> <Plug>(eft-t-repeatable) <SID>map('forward', v:true, v:true)
onoremap <silent><expr> <Plug>(eft-f-repeatable) <SID>map('forward', v:false, v:false)
onoremap <silent><expr> <Plug>(eft-t-repeatable) <SID>map('forward', v:true, v:false)

nnoremap <silent><expr> <Plug>(eft-F-repeatable) <SID>map('backward', v:false, v:true)
nnoremap <silent><expr> <Plug>(eft-T-repeatable) <SID>map('backward', v:true, v:true)
xnoremap <silent><expr> <Plug>(eft-F-repeatable) <SID>map('backward', v:false, v:true)
xnoremap <silent><expr> <Plug>(eft-T-repeatable) <SID>map('backward', v:true, v:true)
onoremap <silent><expr> <Plug>(eft-F-repeatable) <SID>map('backward', v:false, v:false)
onoremap <silent><expr> <Plug>(eft-T-repeatable) <SID>map('backward', v:true, v:false)

" TODO: `onoremap eft-*-repeatable ...` does not needed so we should mark as deprecated.

function! s:map(dir, till, repeat) abort
  let g:_eft_internal_manual = v:true
  return printf("%s:\<C-u>call eft#%s('%s', %s, %s, getcurpos())\<CR>",
  \   s:mode() ==# 'visual' ? "\<Esc>" : '',
  \   a:dir,
  \   s:mode(),
  \   a:till ? 'v:true' : 'v:false',
  \   a:repeat ? 'v:true' : 'v:false'
  \ )
endfunction

function! s:mode() abort
  if index(['no', 'nov', 'noV', "no\<C-V>"], mode(1)) >= 0
    return 'operator-pending'
  elseif index(['v', 'V', "\<C-V>"], mode(1)) >= 0
    return 'visual'
  endif
  return 'normal'
endfunction

