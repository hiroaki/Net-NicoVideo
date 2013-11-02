package Net::NicoVideo::Content::ThumbInfo;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw(Net::NicoVideo::Content);
use XML::TreePP;

use vars qw(@Members);
@Members = qw(
video_id
title
description
thumbnail_url
first_retrieve
length
movie_type
size_high
size_low
view_counter
comment_num
mylist_counter
last_res_body
watch_url
thumb_type
embeddable
no_live_play
tags
user_id
);

__PACKAGE__->mk_accessors(@Members);

sub _status {
    my $self = shift;
    return @_ ? $self->{_status} = shift : $self->{_status};
}

sub is_success {
    $_[0]->_status;
}

sub is_failure {
    not $_[0]->is_success;
}

sub members { # implement
    my @copy = @Members;
    @copy;
}

sub parse { # implement
    my $self = shift;
    $self->load($_[0]) if( defined $_[0] );

    my $tpp = XML::TreePP->new( force_array => 'tags' )
              ->parse($self->_decoded_content);

    my $params = $tpp->{nicovideo_thumb_response} || {};
    my $thumb  = $params->{thumb} || {};

    for my $name ( ($self->members) ){
        $self->$name( $thumb->{$name} )
            if( $self->can($name) );
    }

    my $status = $params->{'-status'} || '';
    $self->_status( lc($status) eq 'ok' ? 1 : 0 );
    
    return $self;
}

1;
