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


1;
__END__
