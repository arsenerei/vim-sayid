syntax match SayidId /:\d\+/
syntax match Function /[[:alpha:][:digit:].-]\+\/[[:alpha:][:digit:]-]\+/

" syntax region SayidSection start="v" end="$"
syntax match SayidSection /^[v|^]/
" FIXME: this removes the highlighting from the above because it matches the
" same region
syntax match SayidSection2 /^|[v|^]/hs=s+1
syntax match SayidArg /\d\+/
syntax keyword SayidReturn returned
syntax match SayidArrow /=>/
syntax region SayidLisp start="(" end=")" skip="(.*)"

highlight link SayidId Keyword
highlight link SayidSection Special
highlight link SayidArg Character
highlight link SayidReturn Label
highlight link SayidArrow String
highlight link SayidSection2 Type
highlight link SayidLisp Label
