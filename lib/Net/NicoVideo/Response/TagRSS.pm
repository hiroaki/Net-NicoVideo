package Net::NicoVideo::Response::TagRSS;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw(Net::NicoVideo::Response);
use Net::NicoVideo::Content::TagRSS;

sub parsed_content { # implement
    my $self = shift;
    Net::NicoVideo::Content::TagRSS->new($self->_component)->parse;
}

sub is_content_success { # implement
    my $self = shift;
    if( $self->parsed_content ){
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
