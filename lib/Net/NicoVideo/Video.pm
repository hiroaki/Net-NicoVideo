# TODO

package Net::NicoVideo::Video;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_01';

use base qw(Class::Accessor::Fast);
use Carp qw(croak);

use vars qw(@Members);
@Members = qw(
content_ref
);

__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}

1;
