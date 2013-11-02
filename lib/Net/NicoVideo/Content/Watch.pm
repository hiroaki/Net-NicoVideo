# TODO

package Net::NicoVideo::Content::Watch;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw(Net::NicoVideo::Content);
use Carp qw(croak);

use vars qw(@Members);
@Members = qw(
decoded_content
);

__PACKAGE__->mk_accessors(@Members);

sub members { # implement
    my @copy = @Members;
    @copy;
}

# TODO - temporary it returns decded_content
sub parse { # implement
    my $self = shift;
    $self->load($_[0]) if( defined $_[0] );

    $self->decoded_content( $self->_decoded_content );
    return $self;
}

1;
__END__
