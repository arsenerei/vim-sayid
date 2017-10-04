" File:         sayid.vim
" Description:  Vim interface for Sayid
" Maintainer:   arsenerei
" Version:      0.1

if exists("g:loaded_sayid") || v:version < 700 || &cp
  finish
endif
let g:loaded_sayid = 1

function! sayid#sayid_buf_query_fn_w_mod_response_parser(response) abort
    let v1 = a:response.value
    let v2 = substitute(v1, '\\"', '"', "g")
    let v3 = substitute(v2, "\\\\n", "\n", "g")
    let v4 = substitute(v3, "\\\\n$", "", "")
    return v4
endfunction

function! sayid#sayid_buf_query_id_w_mod_response_parser(response) abort
    let v1 = a:response.value
    let v2 = substitute(v1, '\\"', '"', "g")
    let v3 = substitute(v2, "\\\\n", "\n", "g")
    let v4 = substitute(v3, "\\\\n$", "", "")
    return v4
endfunction

function! sayid#call(msg) abort
    if !empty(a:msg.op) && fireplace#op_available(a:msg.op)
        let response = fireplace#message(a:msg)[0]
        if get(response, 'value') != ""
            " FIXME: I don't think _every_ Sayid function has this structure.
            " But I may be wrong.
            " NB: sayid-show-traced has non-text formatting data inside the
            " text properties section
            let output = ""
            if a:msg.op == 'sayid-buf-query-id-w-mod'
                let output = sayid#sayid_buf_query_id_w_mod_response_parser(response)
            elseif a:msg.op == 'sayid-buf-query-fn-w-mod'
                let output = sayid#sayid_buf_query_fn_w_mod_response_parser(response)
            else
                let v1 = matchstr(response.value, '".\{-}"')
                let v2 = substitute(v1, '"', '', "g")
                let v3 = substitute(v2, "\\\\n", "\n", "g")
                let v4 = substitute(v3, "\\\\n$", "", "") " remove the extra newline
                let output = v4
            endif

            return output

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
        \ 'sayid-trace-all-ns-in-dir': ['dir'],
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

function! s:query_form_under_cursor() abort
    let current_file = expand('%:p')
    let current_line = line('.')
    let content = sayid#sayid_query_form_at_point(current_file, current_line)
    call sayid#window#replace(content)
endfunction

function! s:trace_ns_in_file() abort
    let current_file = expand('%:p')
    return sayid#sayid_trace_ns_in_file(current_file)
endfunction

function! s:get_workspace() abort
    let current_line = line('.')
    let content = sayid#sayid_get_workspace()
    call sayid#window#replace(content)
endfunction

function! s:trace_fn(type) abort
    let ns = fireplace#ns()
    call sayid#sayid_trace_fn(expand("<cword>"), ns, a:type)
endfunction

function! s:query_id(mod) abort
    normal! $
    let trace_id = substitute(expand("<cword>"), '^:', '',  '')
    let content = sayid#sayid_buf_query_id_w_mod(trace_id, a:mod)
    call sayid#window#replace(content)
endfunction

function! s:query_fn(mod) abort
    normal! ^W
    let fn_name = substitute(expand("<cWORD>"), '^:', '',  '')
    let content = sayid#sayid_buf_query_fn_w_mod(fn_name, a:mod)
    call sayid#window#replace(content)
endfunction

command! SayidQueryUnderCursor :echo s:query_form_under_cursor()
command! SayidClearLog :call sayid#sayid_clear_log()
command! SayidGetWorkspace :call s:get_workspace()
command! SayidShowTraced :echo sayid#sayid_show_traced()
command! SayidTraceNsInFile :silent call s:trace_ns_in_file()
command! SayidTraceFnInner :call s:trace_fn('inner')
command! SayidTraceFnOuter :call s:trace_fn('outer')
command! SayidQueryId :call s:query_id('')
command! SayidQueryIdDescendants :call s:query_id('d')
command! SayidQueryFn :call s:query_fn('')
command! SayidQueryFnDescendants :call s:query_fn('d')

function! sayid#buffer_mappings()
    nnoremap <silent> <buffer> ii :SayidQueryId<CR>
    nnoremap <silent> <buffer> id :SayidQueryIdDescendants<CR>
    nnoremap <silent> <buffer> fi :SayidQueryFn<CR>
    nnoremap <silent> <buffer> fd :SayidQueryFnDescendants<CR>
    nnoremap <silent> <buffer> <BS> :SayidGetWorkspace<CR>
    nnoremap <silent> <buffer> H :SayidGetWorkspace<CR>
endfunction

if get(g:, 'enable_sayid_mappings', 1) == 1
    nnoremap <silent> gsq :SayidQueryUnderCursor<CR>
    nnoremap <silent> gsc :SayidClearLog<CR>
    nnoremap <silent> gsw :SayidGetWorkspace<CR>
    nnoremap <silent> gss :SayidShowTraced<CR>
    nnoremap <silent> gst :SayidTraceNsInFile<CR>
    nnoremap <silent> gsi :SayidTraceFnInner<CR>
    nnoremap <silent> gso :SayidTraceFnOuter<CR>
endif
