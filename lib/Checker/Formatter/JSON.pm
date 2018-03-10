package Checker::Formatter::JSON;
use strict;
use warnings;
use JSON::PP ();

sub new {
    my ($class, $file) = @_;
    my $json = JSON::PP->new->canonical(1)->pretty(1)->indent_length(2)->space_before(0);
    bless { json => $json }, $class;
}

sub format {
    my ($self, @err) = @_;
    $self->{json}->encode(\@err);
}


1;
