syntax match SayidId /:\d\+/
syntax match Function /[[:alpha:][:digit:].-]\+\/[[:alpha:][:digit:]-]\+/

" syntax region SayidSection start="v" end="$"
syntax match SayidSection /^[v|^]/
" README: \@<= *must* be used as opposed to \zs for syntax matching.
syntax match SayidSection2 /\(^|\)\@1<=[v|^]/
syntax match SayidSection3 /\(^||\)\@2<=[v|^]/
syntax match SayidParameter /[-_[:alpha:][:digit:]]\+/ contained
syntax match SayidArg /\d\+/ contained
syntax keyword SayidReturn returned contained
syntax match SayidArrow /=>/ contained
syntax region SayidLisp start="(" end=")" skip="([^)]*)"

highlight link SayidId Keyword
highlight link SayidSection Special
highlight link SayidSection2 Type
highlight link SayidSection3 Repeat
highlight link SayidParameter Character
highlight link SayidArg Character
highlight link SayidReturn Label
highlight link SayidArrow String
highlight link SayidLisp Label
