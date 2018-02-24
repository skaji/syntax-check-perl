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

## Integrate with vim ale

Here is how to integrate with https://github.com/w0rp/ale

```vimrc
Plug 'w0rp/ale'

let g:ale_linters = { 'perl': ['perl'] }
let g:ale_perl_perl_executable = '/path/to/syntax-check.pl'
let g:ale_perl_perl_options = '%s'
```

## Author

Shoichi Kaji

## License

The same as perl
