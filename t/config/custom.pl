use strict;
use warnings;

return {
    compile => {
        inc => {
            libs                 => ['t/lib'],
            replace_default_libs => $ENV{REPLACE_DEFAULT_LIBS} ? 1 : 0,
        }
    },
};
