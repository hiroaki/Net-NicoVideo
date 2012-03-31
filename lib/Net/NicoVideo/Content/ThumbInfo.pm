package Net::NicoVideo::Content::ThumbInfo;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_08';

use base qw(Class::Accessor::Fast);

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

sub members {
    my @copy = @Members;
    @copy;
}

1;
