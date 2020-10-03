# vim-eft

This plugin provides f/t/F/T mappings that can be customized by your setting.

# Usage

You can enable this plugin via following mappings.

```viml
  nmap ; <Plug>(eft-repeat)
  xmap ; <Plug>(eft-repeat)

  nmap f <Plug>(eft-f)
  xmap f <Plug>(eft-f)
  omap f <Plug>(eft-f)
  nmap F <Plug>(eft-F)
  xmap F <Plug>(eft-F)
  omap F <Plug>(eft-F)
  
  nmap t <Plug>(eft-t)
  xmap t <Plug>(eft-t)
  omap t <Plug>(eft-t)
  nmap T <Plug>(eft-T)
  xmap T <Plug>(eft-T)
  omap T <Plug>(eft-T)
```

# Configuration

## highlight

```viml
" Disable highlight
let g:eft_highlight = {}

" Custom highlight
let g:eft_highlight = {
\   '1': {
\     'highlight': 'EftChar',
\     'allow_space': v:true,
\     'allow_operator': v:true,
\   },
\   '2': {
\     'highlight': 'EftSubChar',
\     'allow_space': v:false,
\     'allow_operator': v:false,
\   },
\   'n': {
\     'highlight': 'EftSubChar',
\     'allow_space': v:false,
\     'allow_operator': v:false,
\   }
\ }
```

## character matching

```viml
" You can pick your favorite strategies.
let g:eft_index_function = {
\   'head': function('eft#index#head'),
\   'tail': function('eft#index#tail'),
\   'space': function('eft#index#space'),
\   'camel': function('eft#index#camel'),
\   'symbol': function('eft#index#symbol'),
\ }

" You can use the below function like native `f`
let g:eft_index_function = {
\   'all': { -> v:true },
\ }
```

## DEMO

<img src="https://user-images.githubusercontent.com/629908/94926175-525c1180-04fb-11eb-9080-64ec8c629464.gif" width="480" alt="Usage" />

NOTE: This demo uses `Ff`, `fm` `fc` with this plugin's default configuration.

