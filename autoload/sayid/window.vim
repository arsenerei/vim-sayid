" autoload/sayid/window.vim
" Heavily inspired by scratch.vim

" window handling
let s:buf_name = '__Sayid__'

function! s:activate_autocmds(bufnr)
    if g:scratch_autohide
        augroup ScratchAutoHide
            autocmd!
            execute 'autocmd WinEnter <buffer=' . a:bufnr . '> nested call <SID>close_window(0)'
        augroup END
    endif
endfunction

function! s:deactivate_autocmds()
    augroup ScratchAutoHide
        autocmd!
    augroup END
endfunction

function! s:open_window()
    " open scratch buffer window and move to it. this will create the buffer if
    " necessary.
    let scr_bufnr = bufnr(s:buf_name)
    if scr_bufnr == -1
        execute 'vnew ' . s:buf_name
        setlocal filetype=sayid
        setlocal bufhidden=hide
        setlocal nomodifiable
        setlocal nobuflisted
        setlocal buftype=nofile
        setlocal foldcolumn=0
        setlocal nofoldenable
        setlocal nonumber
        setlocal noswapfile
        " setlocal winfixheight
        " setlocal winfixwidth
        " call s:activate_autocmds(bufnr('%'))
        call sayid#buffer_mappings()
    else
        let scr_winnr = bufwinnr(scr_bufnr)
        if scr_winnr != -1
            if winnr() != scr_winnr
                execute scr_winnr . 'wincmd w'
            endif
        else
            let cmd = 'vsplit'
            execute cmd . ' +buffer' . scr_bufnr
        endif
    endif
endfunction

function! s:close_window(force)
    " close scratch window if it is the last window open, or if force
    if a:force
        let prev_bufnr = bufnr('#')
        let scr_bufnr = bufnr(s:buf_name)
        if scr_bufnr != -1
            " Temporarily deactivate these autocommands to prevent overflow, but
            " still allow other autocommands to be executed.
            call s:deactivate_autocmds()
            close
            execute bufwinnr(prev_bufnr) . 'wincmd w'
            call s:activate_autocmds(scr_bufnr)
        endif
    elseif winbufnr(2) == -1
        if tabpagenr('$') == 1
            bdelete
            quit
        else
            close
        endif
    endif
endfunction

" utility

function! s:resolve_size(size)
    " if a:size is an int, return that number, else it is a float
    " interpret it as a fraction of the screen size and return the
    " corresponding number of lines
    if has('float') && type(a:size) ==# 5 " type number for float
        let win_size = winwidth(0)
        return float2nr(a:size * win_size)
    else
        return a:size
    endif
endfunction

" public functions

function! sayid#window#open()
    " sanity check and open scratch buffer
    if bufname('%') ==# '[Command Line]'
        echoerr 'Unable to open scratch buffer from command line window.'
        return
    endif
    call s:open_window()
    silent normal! G^
endfunction

function! sayid#window#replace(content)
    call sayid#window#open()

    setlocal modifiable
    " Clear the buffer
    silent normal! ggvG"_dd

    " TODO: Figure out why append doesn't output newlines very well.
    " append(0, a:content)
    silent put =a:content

    " Delete the top line
    silent normal! gg"_dd
    setlocal nomodifiable
endfunction

function! sayid#window#preview()
    " toggle scratch window, keeping cursor in current window
    let scr_winnr = bufwinnr(s:buf_name)
    if scr_winnr != -1
        execute scr_winnr . 'close'
    else
        call sayid#window#open(0)
        call s:deactivate_autocmds()
        execute bufwinnr(bufnr('#')) . 'wincmd w'
        call s:activate_autocmds(bufnr(s:buf_name))
    endif
endfunction
