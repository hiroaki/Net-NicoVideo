package Net::NicoVideo::Response::MylistItem;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw/Net::NicoVideo::Response/;
use Net::NicoVideo::Content::MylistItem;

sub parsed_content { # implement
    my $self = shift;
    Net::NicoVideo::Content::MylistItem->new($self->_component)->parse;
}

sub is_content_success { # implement
    my $self = shift;
    my $content = $self->parsed_content;
    if( defined $content->item_id and defined $content->item_type ){
        return 1;
    }else{
        return 0;
    }
}

sub is_content_error { # implement
    not shift->is_content_success;
}

1;
__END__
