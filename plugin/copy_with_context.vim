" Plugin: Copy With Context
" Author: Evgeny Zhdanov evdev34@gmail.com
" Description: Copy lines with file path and line number context

if exists('g:loaded_copy_with_context') || &compatible
  finish
endif
let g:loaded_copy_with_context = 1

" Default mappings
if !exists('g:copy_with_context_mappings')
  let g:copy_with_context_mappings = {
        \ 'relative': '<leader>cy',
        \ 'absolute': '<leader>cY'
        \ }
endif

function! s:CopyWithContext(absolute_path, is_visual) abort
  let [l:start_lnum, l:end_lnum] = [line("'<"), line("'>")]
  let l:lines = a:is_visual
        \ ? getline(l:start_lnum, l:end_lnum)
        \ : [getline('.')]
  let l:content = join(map(l:lines, { _, v -> trim(v) }), "\n")
  let l:line_nums = a:is_visual
        \ ? printf("%d-%d", l:start_lnum, l:end_lnum)
        \ : line('.')
  let l:file_path = a:absolute_path ? expand('%:p') : expand('%')
  let l:output = printf("%s\n# %s:%s", l:content, l:file_path, l:line_nums)
  let @* = l:output
  let @+ = l:output
  echo 'Copied ' . (a:is_visual ? 'selection' : 'line') . ' with context'
endfunction

" Apply mappings
execute 'nnoremap <silent>' g:copy_with_context_mappings.relative ':call <SID>CopyWithContext(0, 0)<CR>'
execute 'nnoremap <silent>' g:copy_with_context_mappings.absolute ':call <SID>CopyWithContext(1, 0)<CR>'
execute 'xnoremap <silent>' g:copy_with_context_mappings.relative ':<C-u>call <SID>CopyWithContext(0, 1)<CR>'
execute 'xnoremap <silent>' g:copy_with_context_mappings.absolute ':<C-u>call <SID>CopyWithContext(1, 1)<CR>'
