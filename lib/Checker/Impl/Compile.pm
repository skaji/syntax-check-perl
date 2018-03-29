package Checker::Impl::Compile;
use strict;
use warnings;
use Config;
use Cwd qw(abs_path getcwd);

sub new {
    my $class = shift;
    bless {}, $class;
}

sub check {
    my ($self, $filename, $tempfile, $lines) = @_;

    my @skip = (
        qr/^Subroutine \S+ redefined/,
        qr/^Name "\S+" used only once/,
        $filename =~ /\.psgi$/
            ? (qr/^Useless use of single ref constructor in void context/)
            : (),
    );

    my @cmd = (@{$self->_cmd}, $tempfile);
    my $pid = open my $fh, "-|";
    if ($pid == 0) {
        open STDERR, ">&", \*STDOUT;
        exec @cmd;
        exit 255;
    }
    my @err;
    while (my $line = <$fh>) {
        next if grep { $line =~ $_ } @skip;
        if (my ($m, $f, $l) = $line =~ /^([^\n]+?) at (.+?) line (\d+)/) {
            if ($f eq $tempfile) {
                push @err, { message => $m, line => 0+$l, from => (ref $self) };
            }
        }
    }
    close $fh;
    @err;
}

sub _cmd {
    my $self = shift;
    my $inc = $self->_inc;
    my $has_indirect = eval { local @INC = (@$inc, @INC); require indirect };

    my @cmd = (
        $^X,
        (map "-I$_", @$inc),
        $has_indirect ? "-M-indirect=fatal" : (),
        "-Mwarnings",
        "-c",
    );
    \@cmd;
}

sub _inc {
    my $self = shift;
    my $version = $Config{version};
    my $back = getcwd;
    my @inc;
    for (1..10) {
        my $cwd = getcwd;
        last if $cwd eq "/";
        my $lib = -d "lib";
        my $local = -d "local/lib/perl5/$version";
        if ($lib or $local) {
            push @inc, abs_path "lib" if $lib;
            push @inc, abs_path "local/lib/perl5" if $local;
            last;
        }
        chdir "..";
    }
    chdir $back;
    \@inc;
}

1;
