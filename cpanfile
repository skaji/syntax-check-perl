recommends 'JSON::PP';

on test => sub {
    requires 'JSON::PP';
    requires 'Capture::Tiny';
    requires 'Test::More';
};
