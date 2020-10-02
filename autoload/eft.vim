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
  let s:state.dir = 'forward'
  let s:state.mode = mode(1)
  let s:state.till = a:till

  let l:after_line = getline('.')[col('.') - (mode(1)[0] ==# 'i' ? 1 : 0) : -1]
  if !a:repeat || !s:repeatable({ 'dir': 'forward', 'till': a:till })
    if g:eft_highlight
      call s:highlight('forward', l:after_line, col('.') + 1)
    endif

    let s:state.char = nr2char(getchar())
    for l:match in getmatches()
      if l:match.group =~# '^Eft'
        call matchdelete(l:match.id)
      endif
    endfor
  endif

  let l:offset = s:compute_offset('forward', l:after_line, s:state.char)
  if l:offset != -1
    if a:till
      let l:offset = l:offset - 1
    endif
    call s:motion(col('.') + l:offset + 1)
  endif
  call timer_start(0, { -> s:reserve_reset() })
endfunction

"
" eft#backward
"
function! eft#backward(till, repeat) abort
  let s:state.dir = 'backward'
  let s:state.mode = mode(1)
  let s:state.till = a:till

  let l:before_line = getline('.')[0 : col('.') - (mode(1)[0] ==# 'i' ? 2 : 1)]
  if !a:repeat || !s:repeatable({ 'dir': 'backward', 'till': a:till })
    if g:eft_highlight
      call s:highlight('backward', l:before_line, 1)
    endif

    let s:state.char = nr2char(getchar())
    for l:match in getmatches()
      if l:match.group =~# '^Eft'
        call matchdelete(l:match.id)
      endif
    endfor
  endif

  let l:offset = s:compute_offset('backward', l:before_line, s:state.char)
  if l:offset != -1
    if !a:till
      let l:offset = l:offset - 1
    endif
    call s:motion(l:offset + 1)
  endif

  call timer_start(0, { -> s:reserve_reset() })
endfunction

"
" eft#index
"
function! eft#index(text, index) abort
  if a:index == 0
    return v:true
  endif

  if strlen(a:text) - 1 == a:index
    return v:true
  endif

  " ignore whitespace
  if a:text[a:index] =~# '\s'
    return v:false
  endif

  " symbols
  if a:text[a:index] =~# '\A'
    return v:true
  endif

  " boundaly
  if a:text[a:index - 1] =~# '\A' && a:text[a:index] =~# '\a'
    return v:true
  endif

  " camel
  if a:text[a:index - 1] =~# '\U' && a:text[a:index] =~# '\u'
    return v:true
  endif

  return v:false
endfunction

"
" motion
"
function! s:motion(col) abort
  augroup eft
    autocmd!
  augroup END

  if index(['no', 'nov', 'noV', "no\<C-v>"], mode(1)) >= 0
    execute printf('normal! v%s|', a:col)
  else
    execute printf('normal! %s|', a:col)
  endif
endfunction

"
" compute_offset
"
function! s:compute_offset(dir, line, char) abort
  if a:dir ==# 'forward'
    for l:i in range(0, strlen(a:line) - 1)
      if l:i != 0 && eft#index(a:line, l:i) && s:match(a:line[l:i], a:char)
        return l:i
      endif
    endfor
  elseif a:dir ==# 'backward'
    for l:i in range(strlen(a:line) - 1, 0, -1)
      if l:i != (strlen(a:line) - 1) && eft#index(a:line, l:i) && s:match(a:line[l:i], a:char)
        return l:i + 1
      endif
    endfor
  endif
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
" highlight
"
function! s:highlight(dir, line, offset_col) abort
  let l:chars = {}
  let l:curr = []
  let l:next = []
  if a:dir ==# 'forward'
    for l:i in range(0, strlen(a:line) - 1)
      if l:i != 0 && eft#index(a:line, l:i)
        if !get(l:chars, a:line[l:i], v:false)
          let l:chars[a:line[l:i]] = v:true
          let l:curr += [l:i]
        else
          let l:next += [l:i]
        endif
      endif
    endfor
  elseif a:dir ==# 'backward'
    for l:i in range(strlen(a:line) - 1, 0, -1)
      if l:i != (strlen(a:line) - 1) && eft#index(a:line, l:i)
        if !get(l:chars, a:line[l:i], v:false)
          let l:chars[a:line[l:i]] = v:true
          let l:curr += [l:i]
        else
          let l:next += [l:i]
        endif
      endif
    endfor
  endif

  let l:ids = []
  for l:h in l:curr
    let l:ids += [matchaddpos('EftChar', [[line('.'), l:h + a:offset_col]])]
  endfor
  for l:h in l:next
    let l:ids += [matchaddpos('EftSubChar', [[line('.'), l:h + a:offset_col]])]
  endfor
  redraw!
  return l:ids
endfunction

"
" repeatable
"
function! s:repeatable(expect) abort
  return !empty(s:state) && s:state.dir == a:expect.dir && s:state.till == a:expect.till && s:state.mode == mode(1) && !empty(get(s:state, 'char', v:null))
endfunction

"
" reserve_reset
"
function! s:reserve_reset() abort
  augroup eft
    autocmd!
    autocmd BufEnter,InsertEnter,CursorMoved <buffer> ++once call eft#clear()
  augroup END
endfunction

