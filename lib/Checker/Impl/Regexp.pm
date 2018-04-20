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
    if ($line =~ /^ \s* my \s* \( (.*?) \) \s* = \s* shift /x) {
        my $args = $1;
        if ($args =~ /,/) {
            return "shift() in list context";
        }
    } elsif ($line =~ /pakcage/) { # no syntax check
        return "spell check 'pakcage'"; # no syntax check
    }

    for my $custom (@{ $self->{check} || [] }) {
        if ($line =~ $custom) {
            return "bad line";
        }
    }

    return;
}

1;
