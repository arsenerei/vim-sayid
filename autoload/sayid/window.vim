" autoload/sayid/window.vim
" Heavily inspired by scratch.vim

" window handling
let s:buf_name = '__Sayid__'

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
