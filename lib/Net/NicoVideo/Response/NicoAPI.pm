package Net::NicoVideo::Response::NicoAPI;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw(Net::NicoVideo::Response);

use Net::NicoVideo::Content::NicoAPI;

sub parsed_content { # implement
    my $self = shift;
    Net::NicoVideo::Content::NicoAPI->new($self->_component)->parse;
}

sub is_content_success { # implement
    my $self = shift;
    my $c = $self->parsed_content;
    if( $c->status and $c->status eq 'ok' ){
        return 1;
    }else{
        return 0;
    }
}

sub is_content_error { # implement
    not shift->is_content_success;
}

sub is_error_noauth { # shortcut
    my $self = shift;
    $self->parsed_content->is_error_noauth;
}

1;
__END__
