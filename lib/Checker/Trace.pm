package Checker::Trace;
use strict;
use warnings;
use Data::Dumper;
use Carp 'shortmess';
use POSIX 'strftime';
use base 'Exporter';

our @EXPORT = ('trace');

my $file = $ENV{HOME} . "/.vim-syntax-check-perl.log";
my $fh;

sub trace {
    if (!$fh) {
        open $fh, ">>:unix", $file or die "$file: $!";
    }
    if (@_ == 1 and ref $_[0]) {
        local $Data::Dumper::Terse = 1;
        local $Data::Dumper::Indent = 1;
        local $Data::Dumper::Useqq = 1;
        local $Data::Dumper::Deparse = 1;
        local $Data::Dumper::Quotekeys = 0;
        local $Data::Dumper::Sortkeys = 1;
        trace(Dumper($_[0]));
        return;
    }
    for my $line (@_) {
        chomp $line;
        print {$fh} shortmess strftime("%F %T", localtime) . " $line";
    }
}

1;
