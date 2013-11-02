# TODO

package Net::NicoVideo::Content::Video;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw(Net::NicoVideo::Content);

use vars qw(@Members);
@Members = qw(
content_ref
);

__PACKAGE__->mk_accessors(@Members);

sub members { # implement
    my @copy = @Members;
    @copy;
}

# TODO - temporary it returning
sub parse { # implement
    my $self = shift;
    $self->load($_[0]) if( defined $_[0] );

    $self->content_ref( $self->_decoded_content );
    return $self;
}

1;
