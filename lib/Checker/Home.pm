package Checker::Home;
use strict;
use warnings;
use Cwd ();
use File::Basename ();
use File::Spec;

my $HOME;

sub get {
    $HOME ||= Cwd::abs_path( File::Spec->catdir(File::Basename::dirname(__FILE__), "..", "..") );
}

1;
