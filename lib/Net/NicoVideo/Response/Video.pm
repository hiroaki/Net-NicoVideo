package Net::NicoVideo::Response::Video;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_08';

use base qw/Net::NicoVideo::Response/;

use Net::NicoVideo::Content::Video;

# TODO - temporary it returning
sub parse {
    my $self = shift;
    $self->{_parsed_content} ||= { content_ref => $self->_component->content_ref };
}

sub parsed_content { # implement
    my $self = shift;
    $self->{_content_object} ||= Net::NicoVideo::Content::Video->new($self->parse);
}

sub is_content_success { # implement
    my $self = shift;
    return ($self->header("X-Died") or $self->header("Client-Aborted")) ? 0 : 1;
}

sub is_content_error { # implement
    not shift->is_content_success;
}

1;
