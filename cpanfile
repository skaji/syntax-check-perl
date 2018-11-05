recommends 'JSON::PP';

on test => sub {
    requires 'JSON::PP';
    requires 'Capture::Tiny';
    requires 'Test::Differences';
    requires 'Test::Fatal';
    requires 'Test::More';
    requires 'File::pushd';
};
