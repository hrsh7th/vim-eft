let s:state = {}

let s:Dir = {}
let s:Dir.Next = 1
let s:Dir.Prev = 2

"
" eft#repeat
"
function! eft#repeat(dir, fallback) abort
  let l:dir = a:dir == s:state.dir ? s:Dir.Next : s:Dir.Prev

  if !empty(s:state) && s:repeatable(l:dir, s:state.till, v:true)
    call s:goto(v:true, l:dir, s:state.till)
  else
    execute 'normal! ' . a:fallback
  endif
endfunction

"
" eft#forward
"
function! eft#forward(args) abort
  let l:repeat = s:repeatable(s:Dir.Next, a:args.till, a:args.repeatable)
  call s:goto(l:repeat, s:Dir.Next, a:args.till)
endfunction

"
" eft#backward
"
function! eft#backward(args) abort
  let l:repeat = s:repeatable(s:Dir.Prev, a:args.till, a:args.repeatable)
  call s:goto(l:repeat, s:Dir.Prev, a:args.till)
endfunction

"
" s:repeatable
"
function! s:repeatable(dir, till, repeatable) abort
  let l:mode = mode(1)
  let l:ok = a:repeatable && !empty(s:state)
  let l:ok = l:ok && get(s:state, 'dir', v:null) == a:dir
  let l:ok = l:ok && get(s:state, 'till', v:null) == a:till
  let l:ok = l:ok && get(s:state, 'mode', v:null) == l:mode
  let l:ok = l:ok && get(s:state, 'curpos', []) == getcurpos()
  let l:ok = l:ok && !(g:_eft_mapping && s:is_operator(l:mode))
  return l:ok || (!empty(s:state) && !g:_eft_mapping)
endfunction

"
" s:goto
"
function! s:goto(repeat, dir, till) abort
  let g:_eft_mapping = v:false

  let l:mode = mode(1)
  let l:curpos = getcurpos()
  let l:line = getline(l:curpos[1])
  let l:col = l:curpos[2]
  let l:indices = a:dir ==# s:Dir.Next ? range(l:col, strlen(l:line)) : range(l:col - 2, 0, -1)

  let l:char = get(s:state, 'char', v:null)
  if !a:repeat
    let l:Clear_highlight = eft#highlight(l:line, l:indices, v:count1, s:is_operator(l:mode))
    let l:char = s:getchar()
    call l:Clear_highlight()
  endif

  if !empty(l:char)
    let l:col = s:compute_col(l:line, l:indices, l:char)
    if l:col != -1
      if a:dir ==# s:Dir.Next && a:till
        let l:col = l:col - 1
      elseif a:dir ==# s:Dir.Prev && a:till
        let l:col = l:col + 1
      endif
      execute printf('normal! %s%s|', (s:is_operator(l:mode) ? 'v' : ''), l:col)

      let s:state.dir = a:dir
      let s:state.till = a:till
      let s:state.char = l:char
      let s:state.mode = l:mode
      let s:state.curpos = getcurpos()
      call s:reserve_reset()
      return
    endif
  end
  if s:is_operator(l:mode)
    call feedkeys("\<Cmd>normal! u\<CR>", 'n')
  end
endfunction

"
" s:reserve_reset
"
function! s:reserve_reset() abort
  augroup eft
    autocmd!
  augroup END
  call feedkeys("\<Cmd>call eft#_reserve_reset()\<CR>", 'n')
endfunction

"
" eft#_reserve_reset
"
function! eft#_reserve_reset() abort
  let s:state.curpos = getcurpos()
  augroup eft
    autocmd!
    autocmd CursorMoved <buffer> call eft#_reset()
  augroup END
endfunction

"
" eft#_reset
"
function! eft#_reset() abort
  if !empty(s:state)
    if s:state.curpos != getcurpos() && !s:is_operator(s:state.mode)
      let s:state = {}
    endif
  endif
endfunction

"
" eft#highlight
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

"
" is_operator
"
function! s:is_operator(mode) abort
  return index(['no', 'nov', 'noV', "no\<C-v>"], a:mode) >= 0
endfunction
