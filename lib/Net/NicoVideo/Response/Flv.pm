package Net::NicoVideo::Response::Flv;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw(Net::NicoVideo::Response);
use Net::NicoVideo::Content::Flv;

sub parsed_content { # implement
    my $self = shift;
    Net::NicoVideo::Content::Flv->new($self->_component)->parse;
}

sub is_content_success { # implement
    my $self = shift;
    my $url = $self->parsed_content->url;
    if( defined $url and $url =~ /nicovideo\.jp/ ){
        return 1;
    }else{
        return 0;
    }
}

sub is_content_error { # implement
    not shift->is_content_success;
}

1;
