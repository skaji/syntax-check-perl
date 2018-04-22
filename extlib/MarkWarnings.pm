package MarkWarnings;
use strict;
use warnings;

$SIG{__WARN__} = sub { warn '=MarkWarnings=', @_ };

1;
