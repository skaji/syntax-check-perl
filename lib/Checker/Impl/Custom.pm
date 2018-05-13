package Checker::Impl::Custom;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    bless { %args }, $class;
}

sub check {
    my ($self, $filename, $tempfile, $lines) = @_;
    my @err;
    for my $i (0 .. $#{$lines}) {
        my $line = $lines->[$i];
        next if $line =~ /no syntax check$/i;
        if (my $err = $self->_check($line, $filename, $lines)) {
            push @err, {
                type => 'ERROR',
                message => 'bad line',
                line => $i+1,
                from => (ref $self),
                (ref $err ? %$err : (message => $err)),
            };
        }
    }
    return @err;
}

sub _check {
    my ($self, $line, $filename, $lines) = @_;
    for my $check (@{ $self->{check} || []}) {
        my $err = eval { $check->($line, $filename, $lines) };
        $err = $@ if $@;
        return $err if $err and $err ne 1;
    }
    return;
}

1;
