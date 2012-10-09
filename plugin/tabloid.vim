command! -count=0 TabloidToggle  call tabloid#set(!&et, <count>)
command! -count=0 TabloidSpacify call tabloid#set(1, <count>)
command! -count=0 TabloidTabify  call tabloid#set(0, <count>)

command! -range=% -nargs=? TabloidFix
			\ call tabloid#fix(<line1>, <line2>, <args>)
