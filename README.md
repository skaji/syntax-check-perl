# syntax checker for perl

## Usage

```console
$ syntax-check -f json script.pl
[
   {
      "line" : 13,
      "message" : "Can't locate TYPO.pm in @INC (you may need to install the TYPO module) (@INC contains: ...)"
   }
]
```

## Integrate with vim plug and ale

Here is how to integrate with https://github.com/junegunn/vim-plug and https://github.com/w0rp/ale

```vim
call plug#begin('~/.vim/plugged')
Plug 'w0rp/ale'
Plug 'skaji/syntax-check-perl'
call plug#end()

let g:ale_linters = { 'perl': ['perl'] }
let g:ale_perl_perl_executable = g:plug_home . '/syntax-check-perl/syntax-check.pl'
let g:ale_perl_perl_options = '%s'
```

## Author

Shoichi Kaji

## License

The same as perl
