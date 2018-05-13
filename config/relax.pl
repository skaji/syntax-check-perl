use strict;
use warnings;

my $filename = $ENV{PERL_SYNTAX_CHECK_FILENAME} || "";

my $config = {
    compile => {
        skip => [
            qr/^Subroutine \S+ redefined/,
            qr/^Name "\S+" used only once/,
            $filename =~ /\.psgi$/
                ? (qr/^Useless use of single ref constructor in void context/)
                : (),
        ],
        use_module => [
            [ "indirect", "-M-indirect=fatal" ],
        ],
    },
    regexp => {
        check => [
            qr/^ \s* my \s* \( (.*?) \) \s* = \s* shift/x,
            qr/pakcage/, # no syntax check
        ],
    },
    custom => {
        check => [
        ]
    },
};
