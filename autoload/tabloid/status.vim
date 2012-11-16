function! tabloid#status#flag()
	let l:flag = tabloid#status#error()
	if empty(l:flag)
		let l:flag = tabloid#status#alert()
	endif
	if empty(l:flag)
		let l:flag = tabloid#status#info()
	endif
	return l:flag
endfunction


function tabloid#status#error()
	return tabloid#haserror() ? '[' . (&et ? '▷' : ' ') . ']' : ''
endfunction


function tabloid#status#alert()
	if shiftwidth() == &ts || &et
		return ''
	endif
	return '[' . shiftwidth() . ' ' . &ts . '▷]'
endfunction


function tabloid#status#info()
	if &et || shiftwidth() == &ts
		return '[' . (&et ? ' ' : '▷') . shiftwidth() . ']'
	endif
	return ''
endfunction
