" Vim script
" Author: Peter Odding
" Last Change: August 31, 2011
" URL: http://peterodding.com/code/vim/session/

" Support for automatic update using the GLVS plug-in.
" GetLatestVimScripts: 3150 1 :AutoInstall: session.zip

" Don't load the plug-in when &compatible is set or it was already loaded.
if &cp || exists('g:loaded_session')
  finish
endif

" When you start Vim without opening any files the plug-in will prompt you
" whether you want to load the default session. Other supported values for
" this option are 'yes' (to load the default session without prompting) and
" 'no' (don't prompt and don't load the default session).
if !exists('g:session_autoload')
  let g:session_autoload = 'prompt'
endif

" When you quit Vim the plug-in will prompt you whether you want to save your
" current session. Other supported values for this option are 'yes' (to save
" the session without prompting) and 'no' (don't prompt and don't save the
" session).
if !exists('g:session_autosave')
  let g:session_autosave = 'prompt'
endif

" The session plug-in can automatically open sessions in three ways: based on
" Vim's server name, by remembering the last used session or by opening the
" session named `default'. Enable this option to use the second approach.
if !exists('g:session_default_to_last')
  let g:session_default_to_last = 0
endif

" The default directory where session scripts are stored.
if !exists('g:session_directory')
  if xolox#misc#os#is_win()
    let g:session_directory = '~\vimfiles\sessions'
  else
    let g:session_directory = '~/.vim/sessions'
  endif
endif

" Make sure the session scripts directory exists and is writable.
let s:directory = fnamemodify(g:session_directory, ':p')
if !isdirectory(s:directory)
  call mkdir(s:directory, 'p')
endif
if filewritable(s:directory) != 2
  let s:msg = "session.vim %s: The sessions directory %s isn't writable!"
  call xolox#misc#msg#warn(s:msg, g:xolox#session#version, string(s:directory))
  unlet s:msg
  finish
endif
unlet s:directory

" Define automatic commands for automatic session management.
augroup PluginSession
  autocmd!
  au VimEnter * nested call xolox#session#auto_load()
  au VimLeavePre * call xolox#session#auto_save()
  au VimLeavePre * call xolox#session#auto_unlock()
  au TabEnter,WinEnter * call xolox#session#auto_dirty_check()
augroup END

" Define commands that enable users to manage multiple named sessions.
command! -bar -bang -nargs=? -complete=customlist,xolox#session#complete_names OpenSession call xolox#session#open_cmd(<q-args>, <q-bang>)
command! -bar -nargs=? -complete=customlist,xolox#session#complete_names ViewSession call xolox#session#view_cmd(<q-args>)
command! -bar -bang -nargs=? -complete=customlist,xolox#session#complete_names SaveSession call xolox#session#save_cmd(<q-args>, <q-bang>)
command! -bar -bang -nargs=? -complete=customlist,xolox#session#complete_names DeleteSession call xolox#session#delete_cmd(<q-args>, <q-bang>)
command! -bar -bang CloseSession call xolox#session#close_cmd(<q-bang>, 0)
command! -bang -nargs=* -complete=command RestartVim call xolox#session#restart_cmd(<q-bang>, <q-args>)

" Don't reload the plug-in once it has loaded successfully.
let g:loaded_session = 1

" vim: ts=2 sw=2 et
