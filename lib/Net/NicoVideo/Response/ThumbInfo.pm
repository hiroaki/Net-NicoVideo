package Net::NicoVideo::Response::ThumbInfo;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_03';

use base qw/Net::NicoVideo::Response/;

use XML::TreePP;
use Net::NicoVideo::ThumbInfo;

sub parse {
    my $self = shift;
    unless( $self->{_parsed_content} ){
        $self->{_parsed_content} = XML::TreePP->new( force_array => 'tags' )->parse($self->_component->decoded_content);
    }
    return $self->{_parsed_content};
}

# check is_success and is_content_success before calling this
sub parsed_content { # implement
    my $self = shift;
    unless( $self->{_parsed_object} ){
        my $tree = $self->parse->{nicovideo_thumb_response}->{thumb};
        my $params = {};
        for my $name ( Net::NicoVideo::ThumbInfo->members ){
            $params->{$name} = $tree->{$name};
        }
        $self->{_parsed_object} = Net::NicoVideo::ThumbInfo->new($params);
    }
    return $self->{_parsed_object};
}

sub is_content_success { # implement
    my $self = shift;

    my $tree = $self->parse;
    if( exists $tree->{nicovideo_thumb_response}
    and exists $tree->{nicovideo_thumb_response}->{'-status'}
    and 'ok' eq lc $tree->{nicovideo_thumb_response}->{'-status'}
    ){
        return 1;
    }else{
        return 0;
    }
}

sub is_content_error { # implement
    not shift->is_content_success
}

1;
