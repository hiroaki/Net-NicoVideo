package Net::NicoVideo::Response::Watch;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw/Net::NicoVideo::Response/;
use Net::NicoVideo::Content::Watch;

sub parsed_content { # implement
    my $self = shift;
    Net::NicoVideo::Content::Watch->new($self->_component)->parse;
}

# TODO - more carefull
sub is_content_success { # implement
    my $self = shift;
    my $contents = $self->_component->decoded_content;
    if( $contents =~ /login/ ){
        return 0;
    }else{
        return 1;
    }
}

sub is_content_error { # implement
    not shift->is_content_success;
}

1;
__END__
