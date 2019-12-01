package Checker::Home;
use strict;
use warnings;
use Cwd ();
use File::Basename ();
use File::Spec;

my $HOME = Cwd::abs_path( File::Spec->catdir(File::Basename::dirname(__FILE__), "..", "..") );

sub get { $HOME }

1;
