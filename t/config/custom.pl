use strict;
use warnings;

return {
    compile => {
        inc => { libs => ['t/lib'], replace => $ENV{REPLACE_LIBS} ? 1 : 0, }
    },
};
