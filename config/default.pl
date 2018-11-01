use strict;
use warnings;

my $filename = $ENV{PERL_SYNTAX_CHECK_FILENAME} || "";

# must return a hash that represents configuration for syntax_check
my $config = {};

__END__

=head1 CONFIGURATION EXAMPLE

  my $config = {

    # for `perl -wc` configuration
    compile => {
        inc => {
            libs                 => [ 'lib', 't/lib', 'xt/lib', ],
            replace_default_libs => 1,
        },
        skip => [
            qr/^Subroutine \S+ redefined/,
        ],
    },

    # check line by regexp
    regexp => {
      check => [
          qr/your common spelling mistake/,
      ],
    },

    # ..and freedom!
    # your custom checker which takes ($line, $filename) as arguments
    custom => {
      check => [
        sub {
          my ($line, $filename) = @_;
          if (
              $filename =~ /my_project/
              &&
              $line =~ /TODO/
          ) {
            return { type => 'WARN', message => 'TODO must be resolved' };
          }
        },
      ]
    },
  };

=head2 compile

The compile section defines the behaviour under which your code is run via the
C<-c> flag.

By default, we add C<lib> and C<local/lib/perl5> to C<@INC>.  If you would like
to add to these paths, use something like this configuration:

  my $config = {
      compile => {
          inc => {
              libs                 => ['foo/bar' 'my-custom-lib' ],
              replace_default_libs => 0,
          },
      },
      ...
  };

This will give you an C<@INC> which includes: C<lib>, C<local/lib/perl>, C<foo/bar> and C<my-custom-lib>

If you would not like the defaults of C<lib> and C<local/lib/perl5> to be added
to C<@INC> you can use the C<replace_default_libs> key:

  my $config = {
    compile => {
        inc => {
            libs                 => [ 'foo/bar' 'my-custom-lib' ],
            replace_default_libs => 1,
        },
    },
      ...
  };

This will give you an C<@INC> which includes: C<foo/bar>, and C<my-custom-lib>

=cut
