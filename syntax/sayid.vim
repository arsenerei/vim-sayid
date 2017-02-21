syntax match SayidId /:\d\+/
syntax match Function /[[:alpha:][:digit:].-]\+\/[[:alpha:][:digit:]-]\+/

" syntax region SayidSection start="v" end="$"
syntax match SayidSection /^[v|^]/
" README: \@<= *must* be used as opposed to \zs for syntax matching.
syntax match SayidSection2 /\(^|\)\@1<=[v|^]/
syntax match SayidSection3 /\(^||\)\@2<=[v|^]/
syntax region SayidLisp start="(" end=")" skip="([^)]*)"
syntax match SayidKeyword /:[-_[:alpha:][:digit:]]\+/
syntax keyword SayidNil nil
syntax keyword SayidBool true false
syntax match SayidNumber /\<\d\+\(\.\d+\)\?/

highlight link SayidId Keyword
highlight link SayidNil Constant
highlight link SayidKeyword Keyword
highlight link SayidNumber Number
highlight link SayidBool Boolean

highlight link SayidSection Special
highlight link SayidSection2 Type
highlight link SayidSection3 Repeat

highlight link SayidLisp Label
