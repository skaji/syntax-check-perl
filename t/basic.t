use strict;
use warnings;
use Test::More;
use Checker;

my $checker = Checker->new;

my @err;

@err = $checker->_run("t/file/cpanfile", "t/file/cpanfile");
is @err, 0 or do { diag explain $_ for @err };

@err = $checker->_run("t/file/alienfile", "t/file/alienfile");
is @err, 0;

@err = $checker->_run("t/file/use_fail.pl", "t/file/use_fail.pl");
is @err, 1;
like $err[0]{message}, qr/Can't locate FOOOOOOOO.pm/;
is $err[0]{line}, 5;

@err = $checker->_run("t/file/misc_fail.pl", "t/file/misc_fail.pl");
is_deeply $err[0], { message => "spell check 'pakcage'", line => 6 }; # no syntax check

@err = $checker->_run("t/file/skip.pl", "t/file/skip.pl");
is @err, 0;

@err = $checker->_run("t/file/invalid.pl", "t/file/invalid.pl");
is @err, 1;
is_deeply $err[0], { message => 'syntax error', line => 4 };

done_testing;
