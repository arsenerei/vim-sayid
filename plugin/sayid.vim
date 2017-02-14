" File:         sayid.vim
" Description:  Vim interface for Sayid
" Maintainer:   arsenerei
" Version:      0.1

if exists("g:loaded_sayid") || v:version < 700 || &cp
  finish
endif
let g:loaded_sayid = 1

function! sayid#call(msg) abort
    if !empty(a:msg.op) && fireplace#op_available(a:msg.op)
        let response = fireplace#message(a:msg)[0]
        if get(response, 'value') != ""
            " FIXME: I don't think _every_ Sayid function has this structure.
            " But I may be wrong.
            " NB: sayid-show-traced has non-text formatting data inside the
            " text properties section
            let v1 = matchstr(response.value, '".\{-}"')
            let v2 = substitute(v1, '"', '', "g")
            let v3 = substitute(v2, "\\\\n", "\n", "g")
            let v4 = substitute(v3, "\\\\n$", "", "") " remove the extra newline

            " If after we extract out the non text formatting data we're left
            " with empty lines let's just return an empty string.
            " if v3 =~ "\n\+"
            "     return ''
            " else
                return v4
            " endif
        else
            " TODO: check me
            return ''
        endif
    else
        throw 'sayid: ' . a:msg.op
            \ . ' is not supported. Do you have Sayid added to your :plugins?'
    endif

endfunction

             " \ 'sayid-gen-instance-expr'
        " \ 'sayid-show-traced': [],
        " \ 'sayid-show-traced': ['ns'],
let s:ops = {
        \ 'sayid-buf-query-fn-w-mod': ['fn-name', 'mod'],
        \ 'sayid-buf-query-id-w-mod': ['trace-id', 'mod'],
        \ 'sayid-clear-log': [],
        \ 'sayid-find-all-ns-roots': [],
        \ 'sayid-get-enabled-trace-count': [],
        \ 'sayid-get-meta-at-point': ['source', 'file', 'line'],
        \ 'sayid-get-trace-count': [],
        \ 'sayid-get-views': ['source', 'file', 'line'],
        \ 'sayid-get-workspace': [],
        \ 'sayid-query-form-at-point': ['file', 'line'],
        \ 'sayid-remove-trace-fn-at-point': ['file', 'line', 'column', 'source'],
        \ 'sayid-show-traced': [],
        \ 'sayid-set-view': ['view-name'],
        \ 'sayid-toggle-view': [],
        \ 'sayid-trace-fn-disable-at-point': ['file', 'line', 'column', 'source'],
        \ 'sayid-trace-fn-disable': ['fn-name', 'fn-ns'],
        \ 'sayid-trace-fn-enable-at-point': ['file', 'line', 'column', 'source'],
        \ 'sayid-trace-fn-enable': ['fn-name', 'fn-ns'],
        \ 'sayid-trace-fn': ['fn-name', 'fn-ns', 'type'],
        \ 'sayid-trace-fn-inner-trace-at-point': ['file', 'line', 'column', 'source'],
        \ 'sayid-trace-fn-outer-trace-at-point': ['file', 'line', 'column', 'source'],
        \ 'sayid-trace-fn-remove': ['fn-name', 'fn-ns'],
        \ 'sayid-trace-ns-disable': ['fn-ns'],
        \ 'sayid-trace-ns-enable': ['fn-ns'],
        \ 'sayid-trace-ns-in-file': ['file'],
        \ 'sayid-trace-ns-remove': ['fn-ns'],
        \ 'sayid-version': [],
        \ }

for [s:op, s:args] in items(s:ops)
    let s:arg_list = ''
    let s:i = 0
    for s:val in s:args
        let s:arg_list .= tr(s:val, '-', '_')
        let s:i = s:i + 1
        if s:i != len(s:args)
            let s:arg_list .= ', '
        endif
    endfor

    let s:call_map = "{'op': '".s:op."'"
    for s:val in s:args
        let s:call_map .= ", " . "'" . s:val . "': a:".tr(s:val, '-', '_')
    endfor
    let s:call_map .= '}'

    execute "function! sayid#".tr(s:op, '-', '_')."(".s:arg_list.")\n"
          \ "  return sayid#call(".s:call_map.")\n"
          \ "endfunction"
endfor

function! s:goto_window(name)
    if bufwinnr(bufnr(a:name)) != -1
        exe bufwinnr(bufnr(a:name)) . "wincmd w"
        return 1
    else
        return 0
    endif
endfunction

function! s:open_window()
    let existing_gundo_buffer = bufnr("__Sayid__")

    if existing_gundo_buffer == -1
        exe "new __Sayid__"
        wincmd H
    else
        let existing_gundo_window = bufwinnr(existing_gundo_buffer)

        if existing_gundo_window != -1
            if winnr() != existing_gundo_window
                exe existing_gundo_window . "wincmd w"
            endif
        endif
    endif
endfunction

function! s:GundoSettingsPreview()
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal filetype=diff
    setlocal nonumber
    setlocal norelativenumber
    setlocal nowrap
    setlocal foldlevel=20
    setlocal foldmethod=diff
endfunction

function! sayid#open_window() abort
    call s:open_window()
    setlocal modifiable
    put =g:res
    setlocal nomodifiable
endfunction

function! s:query_form_under_cursor() abort
    let current_file = expand('%:p')
    let current_line = line('.')
    echo sayid#sayid_query_form_at_point(current_file, current_line)
endfunction

command! SayidQueryUnderCursor :call s:query_form_under_cursor()

nnoremap <silent> gs :sayidqueryundercursor<CR>

augroup SayidAug
    autocmd!
    autocmd BufNewFile __Sayid__ call s:GundoSettingsPreview()
augroup END

