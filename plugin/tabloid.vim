" tabloid.vim - Sensational tabbing.
"
" Author:  Nate Soares <http://so8r.es>
" Version: 1.0
" License: The same as vim itself. (See |license|)

if exists('g:loaded_tabloid') || &cp
	finish
endif
let g:loaded_tabloid = 1


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


command! TabloidNext call tabloid#next()
command! TabloidPrev call tabloid#prev()
command! -count=0 TabloidToggle  call tabloid#set(!&et, <count>)
command! -count=0 TabloidSpacify call tabloid#set(1, <count>)
command! -count=0 TabloidTabify  call tabloid#set(0, <count>)
command! -range=% -nargs=? TabloidFix
		\ call tabloid#fix(<line1>, <line2>, <args>)


if g:tabloid_automap
	noremap <leader>== :TabloidFix<CR>
	noremap <leader>=s :<C-U>call tabloid#set(1, -1)<CR>
	noremap <leader>=t :<C-U>call tabloid#set(0, -1)<CR>
	noremap <leader>=T :<C-U>call tabloid#set(!&et, -1)<CR>
	noremap <leader>=n :TabloidNext<CR>
	noremap <leader>=p :TabloidPrev<CR>
endif
