package Checker::Formatter::ALE;
use strict;
use warnings;

sub new {
    my ($class, $file) = @_;
    bless { file => $file }, $class;
}

my $ALE_WARN = '=MarkWarnings=';

sub format {
    my ($self, @err) = @_;

    my $str = "";
    for my $err (@err) {
        my $prefix = $err->{type} eq 'WARN' ? $ALE_WARN : '';
        $str .= "$prefix$err->{message} at $self->{file} line $err->{line}.\n";
    }
    $str;
}


1;
