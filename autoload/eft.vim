let s:state = {}

"
" eft#repeat
"
function! eft#repeat() abort
  if !empty(s:state)
    call eft#goto(s:state.mode, s:state.till, s:state.char)
  else
    call feedkeys(';', 'n')
  endif
endfunction

"
" eft#forward
"
function! eft#forward(till) abort
  call eft#goto('forward', a:till, '')
endfunction

"
" eft#backward
"
function! eft#backward(till) abort
  call eft#goto('backward', a:till, '')
endfunction

"
" eft#goto
"
function! eft#goto(mode, till, char) abort
  augroup eft
    autocmd!
  augroup END

  let s:state.mode = a:mode
  let s:state.till = a:till
  let s:state.char = empty(a:char) ? nr2char(getchar()) : a:char
  if s:state.mode ==# 'forward'
    call s:forward(s:state.till, s:state.char)
  elseif s:state.mode ==# 'backward'
    call s:backward(s:state.till, s:state.char)
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
" reserve_reset
"
function! s:reserve_reset() abort
  augroup eft
    autocmd!
    autocmd BufEnter,InsertEnter,CursorMoved <buffer> ++once let s:state = {}
  augroup END
endfunction

"
" forward
"
function! s:forward(till, char) abort
  let l:after_line = getline('.')[col('.') - (mode()[0] ==# 'i' ? 1 : 0) : -1]
  let l:offset = s:compute_offset(l:after_line, a:char, 1)
  if l:offset != -1
    if a:till
      let l:offset = l:offset - 1
    endif

    if index(['no', 'nov', 'noV', "no\<C-v>"], mode(1)) >= 0
      execute printf('normal! v%s|', col('.') + l:offset + 1)
    else
      execute printf('normal! %s|', col('.') + l:offset + 1)
    endif
  endif
endfunction

"
" backword
"
function! s:backward(till, char) abort
  let l:before_line = getline('.')[0 : col('.') - (mode()[0] ==# 'i' ? 2 : 1)]
  let l:offset = s:compute_offset(l:before_line, a:char, -1)
  if l:offset != -1
    if !a:till
      let l:offset = l:offset - 1
    endif
    if index(['no', 'nov', 'noV', "no\<C-v>"], mode(1)) >= 0
      execute printf('normal! v%s|', l:offset + 1)
    else
      execute printf('normal! %s|', l:offset + 1)
    endif
  endif
endfunction

"
" compute_offset
"
function! s:compute_offset(line, char, dir) abort
  if a:dir == 1
    for l:i in range(0, strlen(a:line) - 1)
      if l:i != 0 && eft#index(a:line, l:i) && s:match(a:line[l:i], a:char)
        return l:i
      endif
    endfor
  else
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

