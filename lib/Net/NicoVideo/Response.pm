package Net::NicoVideo::Response;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_04';

use base qw/Net::NicoVideo::Decorator/;

sub is_authflagged {
    my $self = shift;
    $self->headers->header('x-niconico-authflag');
}

# a client has to check is_success and is_content_success
# before calling this
sub parsed_content { # abstract
    my $self = shift;
    $self->_component->decoded_content;
}

sub is_content_success { # abstract
    my $self = shift;
    $self->_component->is_success;
}

sub is_content_error { # abstract
    my $self = shift;
    $self->_component->is_error;
}

1;
__END__


=pod

=head1 NAME

Net::NicoVideo::Response - Abstract class decorates with HTTP::Response

=head1 SYNOPSIS

    my $response = Net::NicoVideo::Response->new( $ua->request(...) );
    
=head1 DESCRIPTION

Abstract class decorates with HTTP::Response

=head1 SEE ALSO

L<Net::NicoVideo::Decorator>

=head1 AUTHOR

WATANABE Hiroaki E<lt>hwat@mac.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
