if exists('g:tabloid#autoloaded') || &cp
	finish
endif
let g:tabloid#autoloaded = 1


" Tabloid state flags
let g:tabloid#OK = 0
let g:tabloid#TABS = 1
let g:tabloid#SPACES = 2
let g:tabloid#MIXED = or(g:tabloid#TABS, g:tabloid#SPACES)


" Searches the whole file for a regex.
" Args:
"   {string} regex The regex to search for.
"   {integer} flag The flag to return if found.
" Returns:
"   0 if the regex is not present in the file.
"   flag if the search is present in the file.
function s:flag(regex, flag)
	return search(a:regex, 'nw') == 0 ? 0 : a:flag
endfunction


" Gets the true shiftwidth.
" Returns:
"   The true shift width: &sw, or &ts if &sw is 0.
function! s:sw()
	return &sw > 0 ? &sw : &ts
endfunction


" Creates a string of one character repeated the specified number of times.
" Args:
"   {integer?} n The length of the string. Default: s:sw()
"   {char?} c The character to repeat.
" Returns:
"   A string of c's repeated n times.
function! s:spaces(...)
	let l:n = a:0 > 0 ? a:1 : s:sw()
	let l:c = a:0 > 1 ? a:2 : ' '
	return l:n == 1 ? l:c : join(map(range(l:n), '"'.l:c.'"'), '')
endfunction


" Performs a substitution of pattern for replacement globally in a range.
" Args:
"   {integer} line1 Where to start replacing.
"   {integer} line2 Where to end replacing.
"   {string} pat The pattern to replace.
"   {string} rep The string to replace pat with.
function! s:sub(line1, line2, pat, rep)
	let l:gdefault = &gdefault
	set gdefault
	exe 'silent '.a:line1.','.a:line2.'s/'.a:pat.'/'.a:rep.'/e'
	let &gdefault = l:gdefault
endfunction


" Creates a regex which finds the next improper indent.
" Returns:
"   The regex.
function! s:wrong_regex()
	if &et
		return '\v^ *\t+'
	elseif get(g:tabloid_allow_naked_modeline, &ft, 0)
		return '\v^(\t* +| +(vim?:)@!)'
	else
		return '\v^\t* +'
	endif
endfunction


" Changes the width of space indents in the given range.
" Args:
"   {integer} line1 Where to start.
"   {integer} line2 Where to end.
"   {integer} oldsw The current width of each indent.
"   {integer} newsw The new width of each indent.
function! tabloid#spacewidth(line1, line2, oldsw, newsw)
	if a:oldsw == a:newsw | return | endif
	call s:sub(a:line1, a:line2, '\v(^ *)@<= {'.a:oldsw.'}', s:spaces(a:newsw))
endfunction


" Changes tabs to spaces in the given range.
" Args:
"   {integer} line1 Where to start.
"   {integer} line2 Where to end.
"   {integer} sw How wide to make each new indent.
function! tabloid#tabs2spaces(line1, line2, sw)
	call s:sub(a:line1, a:line2, '\v(^\t*)@<=\t', s:spaces(a:sw))
endfunction


" Changes spaces to tabs in the given range.
" Args:
"   {integer} line1 Where to start.
"   {integer} line2 Where to end.
"   {integer} sw The current width of each indent.
function! tabloid#spaces2tabs(line1, line2, sw)
	call s:sub(a:line1, a:line2, '\v(^ *)@<= {'.a:sw.'}', '\t')
endfunction


" Guesses how many spaces are in an indent level from a given line range.
" Args:
"   {integer} line1 Where to start looking.
"   {integer} line2 Where to stop looking.
function s:guessindent(line1, line2)
	for l:num in range(a:line1, a:line2)
		let l:width = len(substitute(getline(l:num), '\v\S.*$', '', ''))
		if l:width > 0
			return l:width
		endif
	endfor
	return s:sw()
endfunction


" Fixes indentation in the given range.
" Set &et, &sw, and &ts how you like them, then call tabloid#fix to update
" thefile to match.
" Args:
"   {integer} line1 Where to start.
"   {integer} line2 Where to end.
"   {integer?} width The width of space indents currently existing in the range.
"       If there are existing space-indents, tabloid needs to know how wide they
"       are. It guesses at their width by looking at the first space indent in
"       its range. If that's more or less than one indent then you'll need to
"       pass in the width parameter to let tabloid#fix know.
function! tabloid#fix(line1, line2, ...)
	let l:width = a:0 > 0 ? a:1 : 0
	let l:width = l:width == 0 ? s:guessindent(line1, line2) : l:width
	if &et
		if l:width != s:sw()
			call tabloid#spacewidth(a:line1, a:line2, l:width, s:sw())
		endif
		call tabloid#tabs2spaces(a:line1, a:line2, s:sw())
	else
		call tabloid#spaces2tabs(a:line1, a:line2, l:width)
	endif
endfunction


" Set the tabbing of the whole file.
" This is like a souped-up version of :retab that only modifies indent level,
" and which also sets &et, &sw, etc.
" Args:
"   {integer} spaces Whether or not to use spaces for tabbing (0=no)
"   {integer} width How wide to make each indent.
"       If 0, use the current shiftwidth (or tabstop, if &sw is 0.)
"       If -1, use v:count.
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


" Finds the state of tabs and spaces in the file.
" Returns:
"   A set of flags. If the file is using spaces for indents, the flags returned
"   will include g:tabloid#SPACES. If the file is using tabs for indents, the
"   flags returned will include g:tabloid#TABS.
function! tabloid#state()
	let l:tabs = s:flag('\v^\t', g:tabloid#TABS)
	let l:modeline = get(g:tabloid_allow_naked_modeline, &ft, 0)
	let l:space_regex = l:modeline ? '\v^ +(vim?:)@!' : '\v^ '
	let l:spaces = s:flag(l:space_regex, g:tabloid#SPACES)
	let l:tabspaces = s:flag('\v^\t+ ', g:tabloid#MIXED)
	let l:spacetabs = s:flag('\v^ +\t', g:tabloid#MIXED)
	return or(l:tabs, or(l:spaces, or(l:tabspaces, l:spacetabs)))
endfunction


" Creates a statusline message describing the state of the file.
" Returns:
"   '[mixed]' if the file mixes spaces and tabs
"   '[tabs]' if the file has tab indenting when &et is set
"   '[spaces]' if the file has space indenting when &et is not set
"   '' otherwise, or if the filetype is exempt from indentation warnings.
function! tabloid#statusline()
	if get(g:tabloid_exempt, &ft, 0)
		return ''
	endif
	let l:result = tabloid#state()
	if l:result == g:tabloid#MIXED
		return '[mixed]'
	elseif &et && l:result == g:tabloid#TABS
		return '[tabs]'
	elseif !&et && l:result == g:tabloid#SPACES
		return '[spaces]'
	endif
	return ''
endfunction


" Jumps the cursor to the next improperly indented line.
function! tabloid#next()
	call search(s:wrong_regex(), 'w')
endfunction


" Jumps the cursor to the previous improperly indented line.
function! tabloid#prev()
	call search(s:wrong_regex(), 'wb')
endfunction
