function! eft#index#head(state, text, index) abort
  return a:text[a:index - 1] =~# '\A' && a:text[a:index] =~# '\a'
endfunction

function! eft#index#tail(state, text, index) abort
  return a:text[a:index] =~# '\a' && a:text[a:index + 1] =~# '\A'
endfunction

function! eft#index#camel(state, text, index) abort
  return a:text[a:index - 1] =~# '\U' && a:text[a:index] =~# '\u'
endfunction

function! eft#index#symbol(state, text, index) abort
  return a:text[a:index] !~# '\s' && a:text[a:index] =~# '\A'
endfunction

function! eft#index#space(state, text, index) abort
  return a:text[a:index - 1] !~# '\s' && a:text[a:index] =~# '\s'
endfunction

