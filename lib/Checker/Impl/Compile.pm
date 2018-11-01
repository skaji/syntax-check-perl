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

    my @inc = ( Checker::Home->get . '/extlib' );
    push @inc, @{$self->{inc}{libs}} if $self->{inc}{libs};

    my $version = $Config{version};
    my $back = getcwd;

    my @relative = grep { !File::Spec->file_name_is_absolute($_) } @inc;

    # Find project root directory.
    LEVEL:
    for (1..10) {
        last LEVEL if getcwd eq '/';

        # Is this the top level directory for the project?
        for my $dir (@relative) {
            last LEVEL if -d $dir;
        }
        chdir '..';
    }

    # Remove paths which are undefined or do not exist
    @inc = grep { $_ && -d $_ } map{ abs_path($_) } @inc;

    chdir $back;
    \@inc;
}

1;
