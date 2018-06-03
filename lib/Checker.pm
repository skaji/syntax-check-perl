package Checker;
use strict;
use warnings;
use Cwd ();
use File::Basename ();
use File::Spec;
use Getopt::Long qw(:config no_auto_abbrev no_ignore_case bundling);

sub _slurp {
    my $file = shift;
    open my $fh, "<", $file or die "$file: $!";
    my @line = <$fh>;
    chomp @line;
    \@line;
}

# https://gist.github.com/tyru/358703
sub _snake_case {
    my ($s) = @_;
    $s =~ s{(\w+)}{
        ($a = $1) =~ s<(^[A-Z]|(?![a-z])[A-Z])><
            "_" . lc $1
        >eg;
        substr $a, 1;
    }eg;
    $s;
}


sub new {
    my ($class, %args) = @_;
    my @impl = $class->_load_impl;
    bless { impl => \@impl, format => "ale", %args }, $class;
}

sub _load_impl {
    my $class = shift;
    my $dir = File::Spec->catdir(File::Basename::dirname(__FILE__), "Checker", "Impl");
    opendir my $dh, $dir or die "$dir: $!";
    my @impl = map  { "Checker::Impl::$_" }
               grep { s/\.pm$// }
               grep { -f File::Spec->catfile($dir, $_) }
               readdir $dh;
    closedir $dh;
    for my $impl (@impl) {
        eval "require $impl; 1" or die $@;
    }
    @impl;
}

sub _load_config {
    my ($self, $filename) = @_;
    if (!File::Spec->file_name_is_absolute($self->{config_file})) {
        $self->{config_file} = File::Spec->catfile(Cwd::getcwd(), $self->{config_file});
    }
    my $config = do $self->{config_file};
    die "$self->{config_file}: ", $@ || $! unless $config;
    $self->{config} = $config;
}

sub _show_usage {
    my $self = shift;
    die <<"___";
Usage: $0 [options] filename [tempfile]

Options:
  -f, --format  format (ale/json), default: ale
  -h, --help    show this help
  -c, --config  set config file

Examples:
  \$ $0 script.pl
  \$ $0 -f json script.pl
___
}

sub parse_options {
    my ($self, @argv) = @_;
    local @ARGV = @argv;
    Getopt::Long::GetOptions(
        "f|format=s" => \$self->{format},
        "h|help"     => sub { $self->_show_usage },
        "c|config=s" => \$self->{config_file},
    ) or exit 1;
    @ARGV;
}

sub run {
    my $self = shift;
    my ($filename, $tempfile) = $self->parse_options(@_);
    $self->_show_usage unless $filename;
    $tempfile ||= $filename;

    local $ENV{PERL_SYNTAX_CHECK_FILENAME} = $filename;
    $self->_load_config if $self->{config_file};
    my @err = $self->_run($filename, $tempfile);
    my $formatter;
    if ($self->{format} eq "json") {
        require Checker::Formatter::JSON;
        $formatter = Checker::Formatter::JSON->new;
    } else {
        require Checker::Formatter::ALE;
        $formatter = Checker::Formatter::ALE->new($tempfile);
    }
    my $str = $formatter->format(@err);
    print STDERR $str if length $str;
    return @err ? 1 : 0;
}

sub _run {
    my ($self, $filename, $tempfile) = @_;
    return if $filename =~ /\b(?:cpanfile|alienfile)$/;
    my $lines = _slurp $tempfile;
    my $config = $self->{config} || {};

    my @err;
    for my $klass (@{$self->{impl}}) {
        my $copy = $klass;
        $copy =~ s/^Checker::Impl:://;
        my $snake_case_klass = _snake_case $copy;
        my $c = $config->{$snake_case_klass} || {};
        my $impl = $klass->new(%$c);
        my @e = $impl->check($filename, $tempfile, $lines);
        push @err, @e if @e and defined $e[0];
    }
    return @err;
}

1;
