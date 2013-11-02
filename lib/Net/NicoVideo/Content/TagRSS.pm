package Net::NicoVideo::Content::TagRSS;

use strict;
use warnings;
use utf8;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw(Net::NicoVideo::Content Net::NicoVideo::Decorator);
use XML::FeedPP;

sub members { # implement
    ();
}

sub parse { # implement
    my $self = shift;
    $self->load($_[0]) if( defined $_[0] );
    $self->_component( XML::FeedPP->new($self->_decoded_content) );
}

1;
__END__
