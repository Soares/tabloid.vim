" tabloid.vim - Sensational tabbing.
"
" Author:  Nate Soares <http://so8r.es>
" Version: 1.0
" License: The same as vim itself. (See |license|)

if exists('g:loaded_tabloid') || &cp
	finish
endif
let g:loaded_tabloid = 1


" Whether or not to automatically detect and set tab settings.
if !exists('g:tabloid_autodetect')
	let g:tabloid_autodetect = 1
endif


" Filetypes that are exempt from tabloid warnings.
if !exists('g:tabloid_exempt')
	let g:tabloid_exempt = []
endif


" Whether or not to allow spaces after tabs. May be a number, list, or dict.
if !exists('g:tabloid_abide_spaces')
	let g:tabloid_abide_spaces = 1
endif


" Whether or not to make the default key mappings.
if !exists('g:tabloid_automap')
	let g:tabloid_automap = 0
endif


" The regex to match the vimrc script.
if !exists('g:tabloid_vimrc_regex')
	let g:tabloid_vimrc_regex = '\v([\._]vimrc|vim\.rc)$'
endif


" The default tabstop.
if !exists('g:tabloid_default_width')
	let g:tabloid_default_width = 0
endif


command! TabloidNext call tabloid#next()
command! TabloidPrev call tabloid#prev()
command! -count=0 TabloidToggle  call tabloid#set(!&et, <count>)
command! -count=0 TabloidSpacify call tabloid#set(1, <count>)
command! -count=0 TabloidTabify  call tabloid#set(0, <count>)
command! -range=% -nargs=? TabloidFix
		\ call tabloid#fix(<line1>, <line2>, <args>)


if !empty(g:tabloid_autodetect) || type(g:tabloid_autodetect) == type({})
	augroup tabloid
		autocmd!
		autocmd BufRead * call tabloid#detect()
	augroup end
endif


if g:tabloid_automap
	noremap <leader>== :TabloidFix<CR>
	noremap <silent> <leader>=s :<C-U>call tabloid#set(1, -1)<CR>
	noremap <silent> <leader>=t :<C-U>call tabloid#set(0, -1)<CR>
	noremap <silent> <leader>=T :<C-U>call tabloid#set(!&et, -1)<CR>
	noremap <leader>=n :TabloidNext<CR>
	noremap <leader>=p :TabloidPrev<CR>
endif
