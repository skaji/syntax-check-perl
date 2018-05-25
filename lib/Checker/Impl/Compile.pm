package Checker::Impl::Compile;
use strict;
use warnings;
use Config;
use Cwd qw(abs_path getcwd);
use Checker::Home;

sub new {
    my ($class, %args) = @_;
    bless {%args}, $class;
}

sub check {
    my ($self, $filename, $tempfile, $lines) = @_;

    my @cmd = (@{$self->_cmd}, $tempfile);
    my $pid = open my $fh, "-|";
    if ($pid == 0) {
        open STDERR, ">&", \*STDOUT;
        exec @cmd;
        exit 255;
    }
    my @err;
    while (my $line = <$fh>) {
        my $type = $line =~ s/^=MarkWarnings=// ? 'WARN' : 'ERROR'; # must s/// before checking skips
        next if grep { $line =~ $_ } @{ $self->{skip} || [] };
        if (my ($m, $f, $l, $e) = $line =~ /^([^\n]+?) at (.+?) line (\d+)(,.*)?/) {
            if ($f eq $tempfile) {
                $e //= "";
                push @err, { type => $type, message => "$m$e", line => 0+$l, from => (ref $self) };
            }
        }
    }
    close $fh;
    @err;
}

sub _cmd {
    my $self = shift;
    my $inc = $self->_inc;
    my @use_module;
    if (my @module = @{$self->{use_module} || []}) {
        local @INC = (@$inc, @INC);
        for my $module (@module) {
            my ($name, $use) = ref $module ? @$module : ($module, "-M$module");
            push @use_module, $use if eval "require $name"
        }
    }

    my @cmd = (
        $^X,
        (map "-I$_", @$inc),
        "-MMarkWarnings",
        @use_module,
        "-Mwarnings",
        "-c",
    );

    \@cmd;
}

sub _inc {
    my $self = shift;
    my @inc = (Checker::Home->get . "/extlib");
    my $version = $Config{version};
    my $back = getcwd;
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
