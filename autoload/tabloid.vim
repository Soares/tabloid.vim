if exists('g:tabloid#autoloaded') || &cp
	finish
endif
let g:tabloid#autoloaded = 1


" Statusline Message Levels:
let g:tabloid#MESSAGE = 0
let g:tabloid#INFO    = 1
let g:tabloid#WARNING = 2
let g:tabloid#ERROR   = 3


" Regex Parts: All designed for use with \v
let s:xp_spacefollowingspaces     = '(^ *)@<= '
let s:xp_spacefollowingtabs       = '(^\t*)@<= '
let s:xp_spacetab                 = '(^[\t ]*) \t'


" Regexes:
let s:re_et_tabs                  = '\v^ *\t+'
let s:re_linecontent              = '\v\S.*$'
let s:re_noet_onespace            = '\v^\t* '
let s:re_noet_spaces              = '\v^\t* +'
let s:re_spaceindents             = '\v^ +'
let s:re_spacetabs                = '\v^ +\t'
let s:re_tabindent                = '\v(^\t*)@<=\t'
let s:re_tabindents               = '\v^\t+'
let s:re_tabspaces                = '\v^\t+ '
let s:re_tabspacetab              = '\v(^[\t ]*)@<= +\t@='


" Creates a regex which matches each individual space indent.
" @param {integer?} The width of each space indent. Default s:sw().
" @return {string} The regex.
function! s:re_spaceindent(...)
	let l:sw = a:0 > 0 ? a:1 : s:sw()
	return '\v'.s:xp_spacefollowingspaces.'{'.l:sw.'}'
endfunction


" Creates a regex which finds the next improper indent.
" @param {string?} The filetype to generate the regex for. Default &ft.
" @return {string} The regex.
function! s:re_badindent(...)
	let l:ft = a:0 > 0 ? a:1 : &ft
	if &et
		return s:re_et_tabs
	elseif s:spaces_after_tabs()
		return '\v('.s:xp_spacefollowingtabs.'{'.&ts.',}|'.s:xp_spacetab.')'
	else
		return s:re_noet_spaces
	endif
endfunction


" Gets the true shiftwidth.
" @return {integer} The true shift width: &sw, or &ts if &sw is 0.
function! s:sw()
	return &sw > 0 ? &sw : &ts
endfunction


" Whether or not to allow spaces after tabs.
" @param {string?} The filetype to check. Default &ft.
" @return {boolean}
function! s:spaces_after_tabs(...)
	if exists('b:tabloid_abide_spaces')
		return b:tabloid_abide_spaces
	endif
	if type(g:tabloid_abide_spaces) == type(0)
		return g:tabloid_abide_spaces
	endif
	let l:ft = a:0 > 0 ? a:1 : &ft
	if type(g:tabloid_abide_spaces) == type([])
		return index(g:tabloid_abide_spaces, l:ft) > -1
	endif
	if type(g:tabloid_abide_spaces) == type({})
		return get(g:tabloid_abide_spaces, l:ft, 1)
	endif
endfunction


" Creates a string of one character repeated the specified number of times.
" @param {integer?} n The length of the string. Default: s:sw()
" @param {char?} c The character to repeat. Default: space.
" @return {string} c repeated n times.
function! s:spaces(...)
	let l:n = a:0 > 0 ? a:1 : s:sw()
	let l:c = a:0 > 1 ? a:2 : ' '
	return l:n == 1 ? l:c : join(map(range(l:n), '"'.l:c.'"'), '')
endfunction


" Performs a substitution of pattern for replacement globally in a range.
" @param {integer} line1 Where to start replacing.
" @param {integer} line2 Where to end replacing.
" @param {string} pat The pattern to replace.
" @param {string} rep The string to replace pat with.
function! s:sub(line1, line2, pat, rep)
	let l:gdefault = &gdefault
	set nogdefault
	exe 'silent '.a:line1.','.a:line2.'s/'.a:pat.'/'.a:rep.'/ge'
	let &gdefault = l:gdefault
endfunction


" Searches the whole file for a regex.
" @param {string} regex The regex to search for.
" @param {integer} flag The flag to return if found.
" @return {integer} 0 if the regex is not present in the file, a:flag otherwise.
function s:flag(regex, flag)
	return search(a:regex, 'nw') == 0 ? 0 : a:flag
endfunction


" Guesses how many spaces are in an indent level from a given line range.
" @param {integer} line1 Where to start looking.
" @param {integer} line2 Where to stop looking.
" @return {integer} The space indent width.
function s:guessindent(line1, line2)
	for l:num in range(a:line1, a:line2)
		let l:width = len(substitute(getline(l:num), s:re_linecontent, '', ''))
		if l:width > 0
			return l:width
		endif
	endfor
	return s:sw()
endfunction


" Changes the width of space indents in the given range.
" @param {integer} line1 Where to start.
" @param {integer} line2 Where to end.
" @param {integer} oldsw The current width of each indent.
" @param {integer} newsw The new width of each indent.
function! tabloid#spacewidth(line1, line2, oldsw, newsw)
	if a:oldsw == a:newsw | return | endif
	let l:re_spaceindent = s:re_spaceindent(a:oldsw)
	call s:sub(a:line1, a:line2, l:re_spaceindent, s:spaces(a:newsw))
endfunction


" Changes tabs to spaces in the given range.
" @param {integer} line1 Where to start.
" @param {integer} line2 Where to end.
" @param {integer} sw How wide to make each new indent.
function! tabloid#tabs2spaces(line1, line2, sw)
	call s:sub(a:line1, a:line2, s:re_tabindent, s:spaces(a:sw))
endfunction


" Removes any spaces that are found before tab indents in the given range.
" @param {integer} line1 Where to start.
" @param {integer} line2 Where to end.
function! tabloid#cleanspaces(line1, line2)
	call s:sub(a:line1, a:line2, s:re_tabspacetab, '')
endfunction


" Changes spaces to tabs in the given range.
" @param {integer} line1 Where to start.
" @param {integer} line2 Where to end.
" @param {integer} sw The current width of each indent.
function! tabloid#spaces2tabs(line1, line2, sw)
	call s:sub(a:line1, a:line2, s:re_spaceindent(a:sw), '\t')
endfunction


" Fixes indentation in the given range.
" Set &et, &sw, and &ts how you like them, then call tabloid#fix to update
" thefile to match.
" @param {integer} line1 Where to start.
" @param {integer} line2 Where to end.
" @param {integer?} width The width of currently existing space indents.
function! tabloid#fix(line1, line2, ...)
	let l:width = a:0 > 0 ? a:1 : 0
	let l:width = l:width == 0 ? s:guessindent(a:line1, a:line2) : l:width
	if &et
		call tabloid#spacewidth(a:line1, a:line2, l:width, s:sw())
		call tabloid#tabs2spaces(a:line1, a:line2, s:sw())
	else
		call tabloid#spacewidth(a:line1, a:line2, l:width, s:sw())
		call tabloid#spaces2tabs(a:line1, a:line2, &ts)
		call tabloid#cleanspaces(a:line1, a:line2)
	endif
endfunction


" Set the tabbing of the whole file.
" This is like a souped-up version of :retab that only modifies indent level,
" and which also sets &et, &sw, etc.
" @param {integer} spaces Whether or not to use spaces for tabbing (0=no)
" @param {integer} width How wide to make each indent.
"       If 0 use the current shiftwidth. If -1 use v:count.
function! tabloid#set(spaces, width)
	let l:width = a:width == -1 ? v:count : a:width
	let l:width = l:width == 0 ? s:sw() : l:width
	let l:end = line('$')

	if a:spaces
		call tabloid#spacewidth(1, l:end, s:sw(), l:width)
		call tabloid#tabs2spaces(1, l:end, l:width)
	else
		call tabloid#spaces2tabs(1, l:end, s:sw())
	endif

	let &sts = l:width
	let &sw = l:width
	let &ts = l:width
	let &et = !!a:spaces
endfunction!


" Discovers whether or not the file has indentation errors.
" @return {boolean}
function! tabloid#haserror()
	return index(g:tabloid_exempt, &ft) < 0 && search(s:re_badindent(), 'nw')
endfunction


" Creates a statusline message depending on the file's indentation errors.
" @param {integer} mode 0→message, 1→info, 2→warning, 3→error. Default 3.
" @return {string} For use in statusline.
function! tabloid#statusline(...)
	let l:level = a:0 > 0 ? a:1 : g:tabloid#ERROR
	if l:level == g:tabloid#MESSAGE && (&et || s:sw() == &ts)
		return '[' . (&et ? ' ' : '▷') . s:sw() . ']'
	elseif l:level == g:tabloid#INFO && s:sw() != &ts && !&et
		return '[' . s:sw() . ' ' . &ts . '▷]'
	elseif l:level == g:tabloid#ERROR && tabloid#haserror()
		return '[' . (&et ? '▷' : ' ') . ']'
	endif
	return ''
endfunction


" Jumps the cursor to the next improperly indented line.
function! tabloid#next()
	call search(s:re_badindent(), 'w')
endfunction


" Jumps the cursor to the previous improperly indented line.
function! tabloid#prev()
	call search(s:re_badindent(), 'wb')
endfunction
