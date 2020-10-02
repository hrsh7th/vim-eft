let s:state = {}

"
" eft#clear
"
function! eft#clear() abort
  augroup eft
    autocmd!
  augroup END
  let s:state = {}
endfunction

"
" eft#repeat
"
function! eft#repeat() abort
  if !empty(s:state)
    if s:state.dir ==# 'forward'
      call eft#forward(s:state.till, v:true)
    else
      call eft#backward(s:state.till, v:true)
    endif
  else
    call feedkeys(';', 'n')
  endif
endfunction

"
" eft#forward
"
function! eft#forward(till, repeat) abort
  let l:repeat = a:repeat && s:repeatable({ 'dir': 'forward', 'till': a:till })
  let s:state.dir = 'forward'
  let s:state.mode = mode(1)
  let s:state.till = a:till
  call s:goto(l:repeat)
  return ''
endfunction

"
" eft#backward
"
function! eft#backward(till, repeat) abort
  let l:repeat = a:repeat && s:repeatable({ 'dir': 'backward', 'till': a:till })
  let s:state.dir = 'backward'
  let s:state.mode = mode(1)
  let s:state.till = a:till
  call s:goto(l:repeat)
  return ''
endfunction

"
" highlight
"
" NOTE: public for test.
"
function! eft#highlight(line, indices, is_operator_pending) abort
  if !g:eft_highlight
    return { -> {} }
  endif

  let l:chars = {}
  let l:main = []
  let l:sub = []

  for l:i in a:indices
    if s:index(a:line, l:i)
      let l:char = a:line[l:i]
      if !get(l:chars, l:char, v:false)
        let l:chars[l:char] = v:true
        let l:main += [l:i]
      elseif l:char !=# ' ' && !a:is_operator_pending " don't highlight blank sub chars or in operator-pending mode.
        let l:sub += [l:i]
      endif
    endif
  endfor

  let l:ids = []
  let l:ids += map(l:main, 'matchaddpos("EftChar", [[line("."), v:val + 1]])')
  let l:ids += map(l:sub, 'matchaddpos("EftSubChar", [[line("."), v:val + 1]])')
  redraw!
  return { -> map(l:ids, 'matchdelete(v:val)') }
endfunction

"
" goto
"
function! s:goto(repeat) abort
  let l:line = getline('.')
  let l:indices = s:state.dir ==# 'forward'
  \   ? range(col('.'), col('$') - 1)
  \   : range(col('.') - 2, 0, -1)

  if !a:repeat
    let l:Clear_highlight = eft#highlight(l:line, l:indices, s:is_operator_pending())
    let s:state.char = s:getchar()
    call l:Clear_highlight()
  endif

  if empty(s:state.char)
    return eft#clear()
  endif

  call s:reserve_reset()

  let l:offset = s:compute_offset(l:line, l:indices, s:state.char)
  if l:offset != -1
    if s:state.dir ==# 'forward' && s:state.till
      let l:offset = l:offset - 1
    elseif s:state.dir ==# 'backward' && s:state.till
      let l:offset = l:offset + 1
    endif
    call s:motion(l:offset + 1)
  endif
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

  if s:is_operator_pending()
    call feedkeys(printf('v%s|', a:col), 'n')
  else
    call feedkeys(printf('%s|', a:col), 'n')
  endif
endfunction

"
" compute_offset
"
function! s:compute_offset(line, indices, char) abort
  for l:i in a:indices
    if l:i != 0 && s:index(a:line, l:i) && s:match(a:line[l:i], a:char)
      return l:i
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
  return s:state.dir == a:expect.dir && s:state.till == a:expect.till && s:state.mode == mode(1)
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
  return index(['no', 'nov', 'noV', "no\<C-v>"], mode(1)) >= 0
endfunction

"
" getchar
"
function! s:getchar() abort
  if get(g:, 'eft_test_mode', v:false)
    let l:char = input('')
  else
    let l:char = nr2char(getchar())
  endif
  if l:char =~# '[[:print:][:blank:]]'
    return l:char
  endif
  return ''
endfunction

