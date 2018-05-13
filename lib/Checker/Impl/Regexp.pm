package Checker::Impl::Regexp;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    bless {%args}, $class;
}

sub check {
    my ($self, $filename, $tempfile, $lines) = @_;

    my @err;
    for my $i (0 .. $#{$lines}) {
        my $line = $lines->[$i];
        next if $line =~ /no syntax check$/i;
        if (my $message = $self->_check($line)) {
            push @err, { type => 'ERROR', message => $message, line => $i+1, from => (ref $self) };
        }
    }
    return @err;
}

sub _check {
    my ($self, $line) = @_;
    for my $custom (@{ $self->{check} || [] }) {
        if ($line =~ $custom) {
            return "bad line";
        }
    }
    return;
}

1;
