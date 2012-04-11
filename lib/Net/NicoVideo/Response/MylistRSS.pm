package Net::NicoVideo::Response::MylistRSS;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_14';

use base qw/Net::NicoVideo::Response/;

use Net::NicoVideo::Content::MylistRSS;
use XML::FeedPP;

sub parse {
    my $self = shift;
    $self->{_parsed_content} ||= XML::FeedPP->new($self->_component->decoded_content);
}

sub parsed_content { # implement
    my $self = shift;
    $self->{_content_object} ||= Net::NicoVideo::Content::MylistRSS->new($self->parse);
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

sub is_closed { # shortcut
    my $self = shift;
    $self->parsed_content->is_closed;
}

1;
__END__
