package Net::NicoVideo::Response::ThumbInfo;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_08';

use base qw/Net::NicoVideo::Response/;

use XML::TreePP;
use Net::NicoVideo::Content::ThumbInfo;

sub parse {
    my $self = shift;
    unless( $self->{_parsed_content} ){
        $self->{_parsed_content} = XML::TreePP->new( force_array => 'tags' )
                                    ->parse($self->_component->decoded_content);
    }
    return $self->{_parsed_content};
}

sub parsed_content { # implement
    my $self = shift;
    $self->{_parsed_object} ||= Net::NicoVideo::Content::ThumbInfo->new(
                                    $self->parse->{nicovideo_thumb_response}->{thumb});
}

sub is_content_success { # implement
    my $self = shift;
    my $params = $self->parse;
    if( exists $params->{nicovideo_thumb_response}
    and exists $params->{nicovideo_thumb_response}->{'-status'}
    and 'ok' eq lc $params->{nicovideo_thumb_response}->{'-status'}
    ){
        return 1;
    }else{
        return 0;
    }
}

sub is_content_error { # implement
    not shift->is_content_success;
}

1;
