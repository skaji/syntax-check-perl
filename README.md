# Perl syntax checker [![Build Status](https://travis-ci.org/skaji/syntax-check-perl.svg?branch=master)](https://travis-ci.org/skaji/syntax-check-perl)

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
```

The config files are written in Perl, so you can do whatever you want:) See [default.pl](config/default.pl).

## Debugging

You can use `:ALEInfo` in `vim` to troubleshoot `Ale` plugins.  For instance,
if the path to `ale_perl_syntax_check_config` does not exist, the plugin may
fail silently.  Scroll to the bottom of the `:ALEInfo` output to find any
errors which may have been produced by this plugin.

## Author

Shoichi Kaji

## License

The same as perl
