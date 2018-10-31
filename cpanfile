recommends 'JSON::PP';

on test => sub {
    requires 'JSON::PP';
    requires 'Capture::Tiny';
    requires 'Test::Deep';
    requires 'Test::Fatal';
    requires 'Test::More';
};
