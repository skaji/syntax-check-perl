package Checker::Misc;
use strict;
use warnings;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub check {
    my ($self, $filename, $tempfile, $lines) = @_;
    my @err;
    push @err, $self->_package_name($filename, $tempfile, $lines);
    return @err;
}

sub _package_name {
    my ($self, $filename, $tempfile, $lines) = @_;
    my ($package) = $lines->[0] =~ /^package ([a-zA-Z0-9:_]+)/;
    return unless $package;
    my @part = split /::/, $package;
    my $expect = (join "/", @part) . ".pm";
    if ($filename !~ /\Q$expect\E$/) {
        return { message => "package name is incorrect", line => 1 };
    }
    return;
}

1;
