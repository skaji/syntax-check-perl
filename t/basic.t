use strict;
use warnings;
use Capture::Tiny 'capture_merged';
use Checker;
use JSON::PP 'decode_json';

use Test::More;

subtest basic => sub {
    my $checker = Checker->new;
    my @err;
    @err = $checker->_run("t/file/cpanfile", "t/file/cpanfile");
    is @err, 0 or do { diag explain $_ for @err };

    @err = $checker->_run("t/file/alienfile", "t/file/alienfile");
    is @err, 0;

    @err = $checker->_run("t/file/use_fail.pl", "t/file/use_fail.pl");
    is @err, 2;
    like $err[0]{message}, qr/Can't locate FOOOOOOOO.pm/;
    is $err[0]{line}, 5;

    @err = $checker->_run("t/file/misc_fail.pl", "t/file/misc_fail.pl");
    is_deeply $err[0], { message => "spell check 'pakcage'", line => 6, from => 'Checker::Impl::Regexp' }; # no syntax check

    @err = $checker->_run("t/file/skip.pl", "t/file/skip.pl");
    is @err, 0;

    @err = $checker->_run("t/file/invalid.pl", "t/file/invalid.pl");
    is @err, 1;
    is_deeply $err[0], { message => 'syntax error', line => 4, from => 'Checker::Impl::Compile' };
};

subtest output => sub {
    my $checker = Checker->new;
    my ($merged) = capture_merged { $checker->run("t/file/alienfile", "t/file/alienfile") };
    is $merged, "t/file/alienfile syntax OK\n";

    ($merged) = capture_merged { $checker->run("--format", "json", "t/file/use_fail.pl") };
    my $decoded = decode_json($merged);
    like $decoded->[0]{message}, qr/Can't locate FOOOOOOOO.pm/;
    is $decoded->[0]{line}, 5;
};

done_testing;
