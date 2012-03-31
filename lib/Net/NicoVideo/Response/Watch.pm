package Net::NicoVideo::Response::Watch;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_08';

use base qw/Net::NicoVideo::Response/;

use Net::NicoVideo::Content::Watch;

# TODO - temporary it returns decded_content
sub parse {
    my $self = shift;
    $self->{_parsed_content} ||= { decoded_content => $self->_component->decoded_content };
}

sub parsed_content { # implement
    my $self = shift;
    $self->{_content_object} ||= Net::NicoVideo::Content::Watch->new($self->parse);
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
