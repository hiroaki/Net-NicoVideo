package Net::NicoVideo::Response::Flv;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_08';

use base qw/Net::NicoVideo::Response/;

use CGI::Simple;
use Net::NicoVideo::Content::Flv;

sub parse {
    my $self = shift;
    unless( $self->{_parsed_content} ){
        my $cgi = CGI::Simple->new($self->_component->decoded_content);
        my $params = {};
        for ( $cgi->param ){
            $params->{$_} = $cgi->param($_);
        }
        $self->{_parsed_content} = $params;
    }
    return $self->{_parsed_content};
}

sub parsed_content { # implement
    my $self = shift;
    $self->{_content_object} ||= Net::NicoVideo::Content::Flv->new($self->parse);
}

sub is_content_success { # implement
    my $self = shift;
    my $params = $self->parse;
    my $url = $params->{'url'};
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
