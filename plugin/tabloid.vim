if exists('g:loaded_tabloid') || &cp
	finish
endif
let g:loaded_tabloid = 1


command! TabloidNext call tabloid#next()
command! TabloidPrev call tabloid#prev()
command! -count=0 TabloidToggle  call tabloid#set(!&et, <count>)
command! -count=0 TabloidSpacify call tabloid#set(1, <count>)
command! -count=0 TabloidTabify  call tabloid#set(0, <count>)
command! -range=% -nargs=? TabloidFix
			\ call tabloid#fix(<line1>, <line2>, <args>)


if !exists('g:tabloid_exempt')
	let g:tabloid_exempt = {}
endif

if !exists('g:tabloid_allow_naked_modeline')
	let g:tabloid_allow_naked_modeline = {'help': 1}
endif
