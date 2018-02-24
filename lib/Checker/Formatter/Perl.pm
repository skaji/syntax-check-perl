package Checker::Formatter::Perl;
use strict;
use warnings;

sub new {
    my ($class, $file) = @_;
    bless { file => $file }, $class;
}

sub format {
    my ($self, @err) = @_;

    my $str = "";
    for my $err (@err) {
        $str .= "$err->{message} at $self->{file} line $err->{line}.\n";
    }
    $str;
}


1;
