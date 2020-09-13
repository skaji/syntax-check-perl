# Perl syntax checker [![](https://github.com/skaji/syntax-check-perl/workflows/test/badge.svg)](https://github.com/skaji/syntax-check-perl/actions)

This is a Perl syntax checker, especially for [ale](https://github.com/w0rp/ale).

## Integrate with vim-plug and ale

Here is how to integrate with [vim-plug](https://github.com/junegunn/vim-plug) and [ale](https://github.com/w0rp/ale).

```vim
call plug#begin('~/.vim/plugged')
Plug 'w0rp/ale'
Plug 'skaji/syntax-check-perl'
call plug#end()

let g:ale_linters = { 'perl': ['syntax-check'] }
```

## Configuration

If you write Perl a lot, then I assume you have your own favorite for how to check Perl code.
You can set config file for `syntax-check`:

```vim
let g:ale_perl_syntax_check_config = expand('~/.vim/your-config.pl')

" there is also my favorite, and you can use it:)
let g:ale_perl_syntax_check_config = g:plug_home . '/syntax-check-perl/config/relax.pl'

" add arbitrary perl executable names. defaults to "perl"
let g:ale_perl_syntax_check_executable = 'my-perl'
```

The config files are written in Perl, so you can do whatever you want. :) See [default.pl](config/default.pl).

### Adding libs to @INC

By default we try to add `lib` (or `blib` if appropriate), `t/lib`, `xt/lib` and `local/lib/perl5` to `@INC` when attempting
to compile your code.  Depending on how you work, this may not be what you
want.  The good news is that you can manage this via the Perl config file.  See
also [default.pl](config/default.pl) for more detailed information on how to do
this.

## Security

You should be aware that we use the `-c` flag to see if `perl` code compiles.
This does not execute all of the code in a file, but it does run `BEGIN` and
`CHECK` blocks. See `perl --help` and
[StackOverflow](https://stackoverflow.com/a/12908487/406224).

## Debugging

You can use `:ALEInfo` in `vim` to troubleshoot `Ale` plugins.  Scroll to the
bottom of the `:ALEInfo` output to find any errors which may have been produced
by this plugin.

## Author

Shoichi Kaji

## License

The same as perl
