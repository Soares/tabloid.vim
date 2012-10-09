if exists('g:tabloid#autoloaded') || &cp
	finish
endif
let g:tabloid#autoloaded = 1

function! s:sw()
	return &sw > 0 ? &sw : &ts
endfunction

function! s:spaces(count)
	let l:char = a:0 > 0 ? '"'.a:1.'"' : '" "'
	return join(map(range(a:count), l:char), '')
endfunction

function! s:sub(line1, line2, pat, rep)
	let l:gdefault = &gdefault
	set gdefault
	exe 'silent '.a:line1.','.a:line2.'s/'.a:pat.'/'.a:rep.'/e'
	let &gdefault = l:gdefault
endfunction

function! tabloid#spacewidth(line1, line2, oldsw, newsw)
	if a:oldsw == a:newsw | return | endif
	call s:sub(a:line1, a:line2, '\v(^ *)@<= {'.a:oldsw.'}', s:spaces(a:newsw))
endfunction

function! tabloid#tabs2spaces(line1, line2, sw)
	call s:sub(a:line1, a:line2, '\v(^\t*)@<=\t', s:spaces(a:sw))
endfunction

function! tabloid#spaces2tabs(line1, line2, sw)
	call s:sub(a:line1, a:line2, '\v(^ *)@<= {'.a:sw.'}', '\t')
endfunction

function! tabloid#spacealign(line1, line2, sw)
	call s:sub(a:line1, a:line2, '\v(\S.{-})@<=\t', s:spaces(a:sw))
endfunction

function! tabloid#tabalign(line1, line2, sw)
	call s:sub(a:line1, a:line2, '\v(\S.{-})@<= {'.a:sw.'}', '\t')
endfunction

function! tabloid#fix(line1, line2, ...)
	let l:width = a:0 > 0 && a:1 > 0 ? a:1 : s:sw()
	if &et
		if l:width != s:sw()
			call tabloid#spacewidth(a:line1, a:line2, l:width, s:sw())
		endif
		call tabloid#tabs2spaces(a:line1, a:line2, s:sw())
	else
		call tabloid#spaces2tabs(a:line1, a:line2, l:width)
	endif
endfunction

function! tabloid#set(spaces, width)
	if a:width == -1
		let l:width = v:count
	elseif a:width == 0
		let l:width = s:sw()
	else
		let l:width = a:width
	endif
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

function! tabloid#detect()
	let l:tabs = search('^\t', 'nw') != 0
	let l:spaces = search('^ ', 'nw') != 0
	if l:spaces && !l:tabs
		set et
	elseif l:tabs && !l:spaces
		set noet
	else
		echom 'File has mixed tabs and spaces!'
	endif
endfunction
