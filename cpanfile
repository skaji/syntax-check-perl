recommends 'JSON::PP';
requires 'Hash::Merge';

on test => sub {
    requires 'JSON::PP';
    requires 'Capture::Tiny';
    requires 'Test::Differences';
    requires 'Test::Fatal';
    requires 'Test::More';
};
