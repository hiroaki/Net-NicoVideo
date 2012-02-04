# TODO

package Net::NicoVideo::Watch;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_01';

use base qw(Class::Accessor::Fast);
use Carp qw(croak);

use vars qw(@Members);
@Members = qw(
decoded_content
);

__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}

1;
