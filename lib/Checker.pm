package Checker;
use strict;
use warnings;

sub _slurp {
    my $file = shift;
    open my $fh, "<", $file or die "$file: $!";
    my @line = <$fh>;
    chomp @line;
    \@line;
}

sub new {
    my $class = shift;
    my @impl = map "Checker::$_", qw(Compile Regexp Misc);
    bless { impl => \@impl, format => "perl", }, $class;
}

sub _show_usage {
    my $self = shift;
    die <<"___";
Usage: $0 [options] filename [tempfile]

Options:
  -f, --format  format (perl/json), default: perl
  -h, --help    show this help

Examples:
  \$ $0 script.pl
  \$ $0 -f json script.pl
___
}

sub parse_options {
    my ($self, @argv) = @_;
    require Getopt::Long;
    Getopt::Long::Configure(qw(no_auto_abbrev no_ignore_case bundling));
    local @ARGV = @argv;
    Getopt::Long::GetOptions(
        "f|format=s" => \$self->{format},
        "h|help"     => sub { $self->_show_usage },
    );
    @ARGV;
}

sub run {
    my $self = shift;
    my ($filename, $tempfile) = (grep /^-/, @_) ? $self->parse_options(@_) : @_;
    $self->_show_usage unless $filename;
    $tempfile ||= $filename;
    my @err = $self->_run($filename, $tempfile);
    my $formatter;
    if ($self->{format} eq "json") {
        require Checker::Formatter::JSON;
        $formatter = Checker::Formatter::JSON->new;
    } else {
        require Checker::Formatter::Perl;
        $formatter = Checker::Formatter::Perl->new($tempfile);
    }
    my $str = $formatter->format(@err);
    print STDERR $str if length $str;
    return @err ? 1 : 0;
}

sub _run {
    my ($self, $filename, $tempfile) = @_;
    return if $filename =~ /\b(?:cpanfile|alienfile)$/;
    my $lines = _slurp $tempfile;

    my @err;
    for my $klass (@{$self->{impl}}) {
        eval "require $klass; 1" or die $@;
        my $impl = $klass->new;
        my @e = $impl->check($filename, $tempfile, $lines);
        push @err, @e if @e and defined $e[0];
    }
    return @err;
}

1;
