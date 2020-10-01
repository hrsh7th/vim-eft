if exists('g:loaded_eft')
  finish
endif
let g:loaded_eft = v:true

let g:eft_ignorecase = get(g:, 'eft_ignorecase', v:false)

nnoremap <silent> <Plug>(eft-repeat) :<C-u>call eft#repeat()<CR>
xnoremap <silent> <Plug>(eft-repeat) :<C-u>call eft#repeat()<CR>

nnoremap <silent> <Plug>(eft-f) :<C-u>call eft#forward(v:false)<CR>
nnoremap <silent> <Plug>(eft-t) :<C-u>call eft#forward(v:true)<CR>
xnoremap <silent> <Plug>(eft-f) :<C-u>call eft#forward(v:false)<CR>
xnoremap <silent> <Plug>(eft-t) :<C-u>call eft#forward(v:true)<CR>
onoremap <silent> <Plug>(eft-f) :<C-u>call eft#forward(v:false)<CR>
onoremap <silent> <Plug>(eft-t) :<C-u>call eft#forward(v:true)<CR>

nnoremap <silent> <Plug>(eft-F) :<C-u>call eft#backward(v:false)<CR>
nnoremap <silent> <Plug>(eft-T) :<C-u>call eft#backward(v:true)<CR>
xnoremap <silent> <Plug>(eft-F) :<C-u>call eft#backward(v:false)<CR>
xnoremap <silent> <Plug>(eft-T) :<C-u>call eft#backward(v:true)<CR>
onoremap <silent> <Plug>(eft-F) :<C-u>call eft#backward(v:false)<CR>
onoremap <silent> <Plug>(eft-T) :<C-u>call eft#backward(v:true)<CR>

