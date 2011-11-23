package Net::NicoVideo::Response::Flv;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_01';

use base qw/Net::NicoVideo::Response/;

use CGI::Simple;
use XML::TreePP;
use Net::NicoVideo::Flv;

sub parse {
    my $self = shift;
    unless( $self->{_parsed_content} ){
        $self->{_parsed_content} = CGI::Simple->new($self->component->decoded_content);
    }
    return $self->{_parsed_content};
}

# check is_success and is_content_success before calling this
sub parsed_content { # implement
    my $self = shift;

    my $parsed = $self->parse;
    my $params = {};
    for my $name ( Net::NicoVideo::Flv->names ){
        $params->{$name} = $parsed->param($name);
    }
    return Net::NicoVideo::Flv->new($params);
}

sub is_content_success { # implement
    my $self = shift;
    my $url = $self->parse->param('url');
    if( defined $url and $url =~ /nicovideo\.jp/ ){
        return 1;
    }else{
        return 0;
    }
}

sub is_content_error { # implement
    my $self = shift;
    my $url = $self->parse->param('url');
    if( defined $url and $url =~ /nicovideo\.jp/ ){
        return 0;
    }else{
        return 1;
    }
}

1;
