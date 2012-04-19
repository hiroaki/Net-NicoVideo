package Net::NicoVideo::Response::MylistPage;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_17';

use base qw/Net::NicoVideo::Response/;
use Net::NicoVideo::Content::MylistPage;

sub parse {
    my $self = shift;
    $self->{_parsed_content} ||= $self->_component->decoded_content;
}

sub parsed_content { # implement
    my $self = shift;
    unless( $self->{_content_object} ){

        my $params = {};
        my $content = $self->parse;

        if( $content =~ /NicoAPI\.token\s*=\s*"([-\w]+)"/ ){
            $params->{token} = $1;
        }
        
        $self->{_content_object} = Net::NicoVideo::Content::MylistPage->new($params);
    }
    $self->{_content_object};
}

sub is_content_success { # implement
    my $self = shift;
    my $content = $self->parsed_content;
    if( $content->token ){
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
