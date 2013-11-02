package Net::NicoVideo::Response::Thread;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw(Net::NicoVideo::Response);

use Net::NicoVideo::Content::Thread;

sub parsed_content { # implement
    my $self = shift;
    Net::NicoVideo::Content::Thread->new($self->_component)->parse;
}

# TODO
sub is_content_success { # implement
    my $self = shift;
    my $c = $self->parsed_content;
    if( defined $c->resultcode ){
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
