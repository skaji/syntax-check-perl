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

    my @cmd = (@{$self->_cmd($lines->[0])}, $tempfile);
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
                $e = "" unless defined $e;
                push @err, { type => $type, message => "$m$e", line => 0+$l, from => (ref $self) };
            }
        }
    }
    close $fh;
    @err;
}

sub _cmd {
    my $self = shift;
    my $first_line = shift || "";
    my @x = $first_line =~ /^#!/ && $first_line !~ /perl\s*$/ ? ("-x") : ();
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
        @x,
        "-c",
    );

    \@cmd;
}

sub _inc {
    my $self = shift;

    my @inc = ( Checker::Home->get . '/extlib' );
    push @inc, @{$self->{inc}{libs}} if $self->{inc}{libs};
    return \@inc if $self->{inc}{replace_default_libs};

    my $root = $self->{root};

    my $blib;
    if (-d "$root/blib/arch/auto") {
        if (opendir my ($dh), "$root/blib/arch/auto") {
            if (!!grep { $_ ne "." && $_ ne ".." } readdir $dh) {
                push @inc, "$root/blib/arch";
                push @inc, "$root/blib/lib";
                $blib++;
            }
            closedir $dh;
        }
    }
    push @inc, "$root/lib" if !$blib && -d "$root/lib";
    push @inc, "$root/t/lib" if -d "$root/t/lib";
    push @inc, "$root/xt/lib" if -d "$root/xt/lib";
    push @inc, "$root/local/lib/perl5" if -d "$root/local/lib/perl5/$Config{version}";
    \@inc;
}

1;
