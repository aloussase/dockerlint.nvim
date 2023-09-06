if exists('g:dockerlint_loaded') 
    finish
endif

let g:dockerlint_loaded = 1

command! -nargs=0 DockerLint lua require('dockerlint').dockerlint(vim.fn.bufnr())
