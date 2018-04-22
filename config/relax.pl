use strict;
use warnings;

# this is my favorite for syntax_check :)

my $filename = $ENV{PERL_SYNTAX_CHECK_FILENAME} || "";

my @skip = (
    qr/^Subroutine \S+ redefined/,
    qr/^Name "\S+" used only once/,
    $filename =~ /\.psgi$/
        ? (qr/^Useless use of single ref constructor in void context/)
        : (),
);

# must return a hash that represents configuration for syntax_check
my $config = {
    compile => {
        skip => \@skip
    },
};
