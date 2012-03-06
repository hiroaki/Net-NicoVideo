package Net::NicoVideo::Response::MyList;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_07';

use base qw/Net::NicoVideo::Response/;

use Net::NicoVideo::MyList;
use XML::FeedPP;

sub parse {
    my $self = shift;

    unless( $self->{_parsed_content} ){
        $self->{_parsed_content} = XML::FeedPP->new($self->_component->decoded_content);
    }
    return $self->{_parsed_content};
}

sub parsed_content { # implement
    my $self = shift;
    $self->{_content_object} ||= Net::NicoVideo::MyList->new($self->parse);
}

sub is_content_success { # implement
    my $self = shift;
    if( $self->parse ){
        return 1;
    }else{
        return 0;
    }
}

sub is_content_error { # implement
    not shift->is_content_success;
}

1;
