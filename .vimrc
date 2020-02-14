"-------General--------"
set nocompatible		            " be iMproved, required
"let mapleader = ','		        " The default leader is '\', but a comma is much better
":cabbrev help tab help             " Open help in a separate tab.      
set number			                " Let's activate line numbers
set relativenumber                  " Set relative nubmers
set ruler
set backspace=indent,eol,start      " Make backspace behave like every other editors
set noerrorbells visualbell t_vb=   " No dump bells!
set autowriteall                    " Automatically write the file when switching buffers
set autowrite                       " Write any changes
set undofile                        " Save changes in the undofile. Even after reopen a file you can do undo things
set undodir=~/.vim/undo
set wildmode=list:longest,full      " Show suggestions while hit <tab> in a command mode
set path=.,,**                      " Find a file in the directory of the current file or the current directory, recursively
set directory^=~/.vim/swaps         " Set the directory where all swaps filesliv
set textwidth=0                   " Stop wrapping text
:filetype plugin on                 " Enable file type detection


"--------Visuals--------"
syntax enable
set t_CO=256			        " Use 256 colors. This is useful for Terminal Vim.
let g:solarized_termtrans=1     " Terminal setting for color
colorscheme solarized
let &t_SI = "\e[6 q"            " Set cursore shape
let &t_EI = "\e[2 q"            " Set cursore shape

highlight VertSplit ctermbg=NONE guibg=NONE     " color of vertical split color
set fillchars+=vert:│                           " shape of vertical split

highlight LineNr ctermfg=11 ctermbg=8      " Set a color of a left colunm


"--------Search--------"
set hlsearch
set incsearch


"--------Tabs--------"
:set tabstop=4
:set softtabstop=4
:set shiftwidth=4
:set expandtab      " Expand tab to spaces


"--------Windows--------"
set splitright
set splitbelow


"--------Mappings--------"
" Make it easy to edit the Vimrc file.
nmap <Leader>ev :tabedit $MYVIMRC<CR>
nmap <Leader>es :e ~/.vim/snippets<CR>

nmap <Leader><space> :nohlsearch<CR> " Add simple highlight removal.

" Make NERDTree easier to toggle.
nmap <Leader>b :NERDTreeToggle<CR>

" Move lines
"nnoremap <S-k> :m .-2<CR>==
"nnoremap <S-j> :m .+1<CR>==
"vnoremap <S-k> :m '<-2<CR>gv=gv
"vnoremap <S-j> :m '>+1<CR>gv=gv
inoremap <Leader>k <Esc>:m .-2<CR>==gi
inoremap <Leader>j <Esc>:m .+1<CR>==gi

" Scroll screen with a cursor
nnoremap <Leader>j jzz
nnoremap <Leader>k kzz

" Go project specifig mappings
nmap <Leader><Leader>c :CtrlP<CR>config/config.go
nmap <Leader><Leader>s :e configs<CR>

" Write automaticaly when exit the insert mode
inoremap <Esc> <Esc>:w<CR>


"--------Plugins--------"
"/
"/ netrw
"/
let g:netrw_banner = 0          " No header spam in directory mode
let g:netrw_liststyle = 3       " Tree style

"/
"/ CtrlP
"/
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|vendor|node_modules|DS_Store|idea|vscode)$',
  \ 'file': '\v\.()$',
  \ }
let g:ctrlp_show_hidden = 1
"set wildignore+=.git
"nmap <c-R> :CtrlPBufTag<cr>


"/
"/ fzf.vim
"/
set rtp+=/usr/local/opt/fzf
let g:fzf_command_prefix = "Fzf"            " Add namespace for fzf.vim exported commands

nnoremap <silent> <leader>ff :FzfFiles<CR>
nnoremap <silent> <leader>fF :FzfFiles!<CR>
nnoremap <silent> <leader>fb :FzfBuffers<CR>
nnoremap <silent> <leader>fch :FzfHistory:<CR>
nnoremap <silent> <leader>fcc :FzfCommands:<CR>
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)


"/
"/ vim-xkbswitch
"/
let g:XkbSwitchEnabled = 1
" keymap=russian-jcukenwin


"/
"/ vim-go
"/
let g:go_fmt_command = "goimports"
let g:go_mod_fmt_autosave = 1                               " Apply fmt to the current file and go.mod
let g:go_decls_mode = 'fzf'
let g:go_list_type = "quickfix"
let g:go_auto_type_info = 1                                 " Show info of the object under the curson in status bar
let g:go_auto_sameids = 0                                   " Highlighting the same objects
let g:go_snippet_case_type = "camelcase"                    " Set the camelcase output for snippets
let g:go_updatetime=100                                     " Set update interval to 100ms

" Metalinter
"let g:go_debug = ["shell-commands", "debugger-state"]
"let g:go_metalinter_command = "golangci-lint run --print-issued-lines=false --build-tags --exclude-use-default=false --enable-all"
"let g:syntastic_go_gometalinter_args = ['--enable-all', '--enable=errcheck']
let g:go_metalinter_enabled = ['wsl']
let g:go_metalinter_autosave = 1

" Syntax
let g:go_highlight_extra_types = 1                          " Highlight commonly used library types (`io.Reader`, etc.). >
let g:go_highlight_operators = 1                            " Highlight operators such as `:=` , `==`, `-=`, etc.
let g:go_highlight_functions = 1                            " Highlight function and method declarations.
let g:go_highlight_function_parameters = 1                  " Highlight the variable names in parameters (including named return parameters) in function declarations.
let g:go_highlight_function_calls = 1                       " Highlight function and method calls.
let g:go_highlight_types = 1                                " Highlight struct and interface names.
let g:go_highlight_fields = 1                               " Highlight struct field names.
let g:go_highlight_build_constraints = 1                    " Highlights build constraints.
let g:go_highlight_generate_tags = 1                        " Highlight go:generate directives.
let g:go_highlight_variable_declarations = 1                " Highlight variable names in variable declarations (`x` in ` x :=`).
let g:go_highlight_variable_assignments = 1                 " Highlight variable names in variable assignments (`x` in `x =`).

" Mapping
autocmd FileType go nmap <leader>gp  :cprevious<CR>
autocmd FileType go nmap <leader>gn  :cnext<CR>
autocmd FileType go nmap <leader>gb  <Plug>(go-build)
autocmd FileType go nmap <leader>gr  <Plug>(go-run)
autocmd FileType go nmap <leader>gd  <Plug>(go-debug)
autocmd FileType go nmap <leader>gi  <Plug>(go-info)
autocmd FileType go nmap <leader>gt  :GoDecls<CR>
autocmd FileType go nmap <leader>gs  :GoSameIdsAutoToggle<CR>

"--------Auto-Commands--------"
"Automatically source the Vimrc file on save.
augroup autosourcing
	autocmd!
	autocmd BufWritePost .vimrc source %
augroup END


" Notes and Tips
" zz    center the line where the cursor is located
" ZZ    quit :q
" di(   delete inside ()
" ai(   delete and edit inside ()
" :wa   save all files
" <S-j> join lines
" yiw   yank inner word
" 
"
" Visual mode
" s     start edit
" vit   select everything inside tags
" <S-<> untend 
" <S->  intend
" 
" Splits
" :sp       horisontal split
" :vsp      vertical split
" <C-w>|    expand current split
" <C-w>=    normalize splits
" <C-w>o        current buffer full screen
" 
" 
" Tab managment
" gT        go to previous tab
" gt        go to next tab
" {i}gt     go to tab in position i
"
"
" Search
" :grep -R "" .
" :copen
"
"
" Buffers
" :bufdo bd!    close every buffer
" <C-^>         back to a previous buffer
" :b{i}         go to buffer i
" :sbuffer{i}   open buffer i in split 
"
"
" Completeon
" <C-n>             suggestion dropdown 
" <C-n><C-n>        cycle trought a suggestion dropdown
" set complet       show completeon settings (. current file
"                                             w all open window
"                                             b loaded buffer
"                                             u unloaded buffer)
"
"
" Folds
" za            open all folds
" zo            open current fold
" zc            close fold
"
"
" CtrlP
" <c-p>             open file
" :CrtlPBufTag      navigate inside files
" :CtrlPMRUFiles    MRU (Most Resently Used)
"
" Surround
" cs'"      change surround ' to "
" ds"       delete surround "
" S<tag>    surround text with tag
