package Net::NicoVideo::Response::Video;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw/Net::NicoVideo::Response/;
use Net::NicoVideo::Content::Video;

sub parsed_content { # implement
    my $self = shift;
    Net::NicoVideo::Content::Video->new($self->_component)->parse;
}

sub is_content_success { # implement
    my $self = shift;
    return ($self->header("X-Died") or $self->header("Client-Aborted")) ? 0 : 1;
}

sub is_content_error { # implement
    not shift->is_content_success;
}

1;
