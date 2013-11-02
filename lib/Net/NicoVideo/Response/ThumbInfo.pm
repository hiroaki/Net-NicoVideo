package Net::NicoVideo::Response::ThumbInfo;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw/Net::NicoVideo::Response/;
use Net::NicoVideo::Content::ThumbInfo;

sub parsed_content { # implement
    my $self = shift;
    Net::NicoVideo::Content::ThumbInfo->new($self->_component)->parse;
}

sub is_content_success { # implement
    $_[0]->parsed_content->is_success;
}

sub is_content_error { # implement
    $_[0]->parsed_content->is_failure;
}

1;
