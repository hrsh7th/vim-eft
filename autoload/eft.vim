let s:state = {}

"
" eft#clear
"
function! eft#clear(...) abort
  augroup eft
    autocmd!
  augroup END
  if !s:is_operator_pending() || get(a:000, 0, v:false)
    let s:state = {}
  endif
endfunction

"
" eft#repeat
"
function! eft#repeat() abort
  if !empty(s:state)
    if s:state.dir ==# 'forward'
      call eft#forward(s:state.mode, s:state.till, v:true)
    else
      call eft#backward(s:state.mode, s:state.till, v:true)
    endif
  else
    normal! ;
  endif
endfunction

"
" eft#forward
"
function! eft#forward(mode, till, repeat) abort
  let l:repeat = (a:repeat || !g:_eft_internal_manual) && s:repeatable({
  \   'dir': 'forward',
  \   'till': a:till,
  \   'mode': a:mode,
  \   'cursor': getpos('.'),
  \ })
  let s:state.dir = 'forward'
  let s:state.mode = a:mode
  let s:state.till = a:till
  return s:goto(l:repeat)
endfunction

"
" eft#backward
"
function! eft#backward(mode, till, repeat) abort
  let l:repeat = (a:repeat || !g:_eft_internal_manual) && s:repeatable({
  \   'dir': 'backward',
  \   'till': a:till,
  \   'mode': a:mode,
  \   'cursor': getpos('.'),
  \ })
  let s:state.dir = 'backward'
  let s:state.mode = a:mode
  let s:state.till = a:till
  return s:goto(l:repeat)
endfunction

"
" eft#goto
"
" NOTE: publis for mapping
"
function! s:goto(repeat) abort
  let g:_eft_internal_manual = v:false

  let l:line = getline('.')
  let l:col = col('.') " In visual-mode, does not returns valid `col('.')` when ; repeat.
  let l:indices = s:state.dir ==# 'forward'
  \   ? range(l:col, col('$') - 1)
  \   : range(l:col - 2, 0, -1)

  if !a:repeat
    let l:Clear_highlight = eft#highlight(l:line, l:indices, v:count1, s:is_operator_pending())
    let s:state.char = s:getchar()
    call l:Clear_highlight()
  endif

  if !empty(s:state.char)
    let l:col = s:compute_col(l:line, l:indices, s:state.char)
    if l:col != -1
      if s:state.dir ==# 'forward' && s:state.till
        let l:col = l:col - 1
      elseif s:state.dir ==# 'backward' && s:state.till
        let l:col = l:col + 1
      endif
      call s:motion(l:col)
    endif
  end

  if s:is_visual() " should restore visual-mode for mapping (`:<C-u>...<CR>`).
    normal! gv
  endif
endfunction

"
" eft#highlight
"
" NOTE: public for test.
"
function! eft#highlight(line, indices, count, is_operator_pending) abort
  if empty(g:eft_highlight)
    return { -> {} }
  endif

  let l:chars = {}
  let l:highs = []

  for l:i in a:indices
    if s:index(a:line, l:i)
      let l:char = a:line[l:i]
      if !has_key(l:chars, l:char)
        let l:chars[l:char] = 0
      endif
      let l:chars[l:char] = l:chars[l:char] + 1

      let l:count = (l:chars[l:char] - a:count) + 1
      if l:count < 0
        continue
      endif 

      let l:config = get(g:eft_highlight, l:count, get(g:eft_highlight, 'n', v:null))

      let l:ok = v:true
      let l:ok = l:ok && l:config isnot# v:null
      let l:ok = l:ok && (get(l:config, 'allow_space', v:false) || l:char !~# '[[:blank:]]')
      let l:ok = l:ok && (get(l:config, 'allow_operator', v:false) || !a:is_operator_pending)
      if l:ok
        call add(l:highs, [l:config.highlight, l:i + 1, l:char])
      endif
    endif
  endfor

  let l:ids = map(l:highs, 'matchaddpos(v:val[0], [[line("."), v:val[1]]])')
  redraw
  return { -> map(l:ids, 'matchdelete(v:val)') }
endfunction

"
" index
"
function! s:index(text, index) abort
  if a:index == 0 || strlen(a:text) - 1 == a:index " ignore chars to adjacent to cursor
    return v:true
  endif

  for [l:name, l:Index] in items(g:eft_index_function)
    if l:Index(s:state, a:text, a:index)
      return v:true
    endif
  endfor

  return v:false
endfunction

"
" motion
"
function! s:motion(col) abort
  augroup eft
    autocmd!
  augroup END

  let l:ctx = {}
  function! l:ctx.callback(col) abort
    if s:is_operator_pending()
      execute printf('normal! v%s|', a:col)
    elseif s:is_visual()
      execute printf('normal! gv%s|', a:col)
    else
      execute printf('normal! %s|', a:col)
    endif
    let s:state.cursor = getpos('.')
    call s:reserve_reset()
  endfunction
  call timer_start(0, { -> l:ctx.callback(a:col) })
endfunction

"
" compute_col
"
function! s:compute_col(line, indices, char) abort
  let l:count = v:count1
  for l:i in a:indices
    if l:i != 0 && s:index(a:line, l:i) && s:match(a:line[l:i], a:char)
      let l:count -= 1
      if l:count == 0
        return strdisplaywidth(a:line[0 : l:i])
      endif
    endif
  endfor
  return -1
endfunction

"
" match
"
function! s:match(char1, char2) abort
  if g:eft_ignorecase
    return a:char1 ==? a:char2
  endif
  return a:char1 ==# a:char2
endfunction

"
" repeatable
"
function! s:repeatable(expect) abort
  if empty(s:state)
    return v:false
  endif
  if empty(get(s:state, 'char', v:null))
    return v:false
  endif
  return s:state.dir ==# a:expect.dir && s:state.till == a:expect.till && s:state.mode ==# a:expect.mode && get(s:state, 'cursor', []) == a:expect.cursor
endfunction

"
" reserve_reset
"
function! s:reserve_reset() abort
  augroup eft
    autocmd!
  augroup END

  let l:ctx = {}
  function! l:ctx.callback() abort
    augroup eft
      autocmd!
      autocmd BufEnter,InsertEnter,CursorMoved <buffer> ++once call eft#clear()
    augroup END
  endfunction
  call timer_start(0, { -> l:ctx.callback() })
endfunction

"
" is_operator_pending
"
function! s:is_operator_pending() abort
  return has_key(s:state, 'mode') && index(['no', 'nov', 'noV', "no\<C-v>"], s:state.mode) >= 0
endfunction

"
" is_visual
"
function! s:is_visual() abort
  return has_key(s:state, 'mode') && index(['v', 'V', "\<C-v>"], s:state.mode) >= 0
endfunction

"
" getchar
"
function! s:getchar() abort
  let l:char = nr2char(getchar())
  redraw
  if l:char =~# '[[:print:][:blank:]]'
    return l:char
  endif
  return ''
endfunction

