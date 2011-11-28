package Net::NicoVideo::UserAgent;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_03';

use base qw/Net::NicoVideo::Decorator/;

use Carp qw/croak/;
use HTTP::Cookies;
use HTTP::Request::Common;
use Net::NicoVideo::Response;
use Net::NicoVideo::Response::Flv;
use Net::NicoVideo::Response::ThumbInfo;

sub new {
    my ($class, $component, $opts) = @_;

    croak "component is not a 'LWP::UserAgent'"
        unless( $component->isa('LWP::UserAgent') );

    $class->SUPER::new($component);
}

sub nicovideo_email {
    my $self = shift;
    return @_ ? $self->{nicovideo_email} = shift : $self->{nicovideo_email};
}

sub nicovideo_password {
    my $self = shift;
    return @_ ? $self->{nicovideo_password} = shift : $self->{nicovideo_password};
}

sub login {
    my ($self, $res) = @_;

    my $cookie_jar = HTTP::Cookies->new;
    $cookie_jar->extract_cookies($res);
    $self->cookie_jar($cookie_jar);

    return $self;
}

sub request_login {
    my ($self, $email, $password) = @_;
    my $url = 'https://secure.nicovideo.jp/secure/login?site=niconico';
    my $res = Net::NicoVideo::Response->new(
                $self->request(POST $url, [
                    next_url    => '',
                    mail        => $email,
                    password    => $password,
                    ]));

    croak "Request 'login' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    return $res;
}

sub request_thumbinfo {
    my ($self, $video_id) = @_;
    my $url = 'http://ext.nicovideo.jp/api/getthumbinfo/'.$video_id;
    my $res = Net::NicoVideo::Response::ThumbInfo->new( $self->request(GET $url) );

    croak "API 'getthumbinfo' is error: @{[ $res->status_line ]}"
        if( $res->is_error );
    
    croak "Invalid content as 'getthumbinfo': @{[ $res->content ]}\n"
        if( $res->is_content_error );

    return $res;
}

sub request_flv {
    my ($self, $video_id, $email, $password) = @_;
    my $url = 'http://flapi.nicovideo.jp/api/getflv/'.$video_id;

    my $params = $video_id =~ /^nm/ ? ['as3' => 1] : [];
    
    my $res = Net::NicoVideo::Response::Flv->new( $self->request(POST $url, $params) );

    croak "API 'getflv' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    unless( $res->is_authflagged ){
        $self->login($self->request_login($email, $password));
        $res = Net::NicoVideo::Response::Flv->new( $self->request(POST $url, $params) );
        croak "Cannot login because specified account is something wrong"
            unless( $res->is_authflagged );
    }

    croak "Invalid content as 'getflv': @{[ $res->content ]}\n"
        if( $res->is_content_error );

    return $res;    
}

sub request_watching {
    my ($self, $video_id, $email, $password) = @_;
    my $url = 'http://www.nicovideo.jp/watch/'.$video_id;

    my $res = Net::NicoVideo::Response->new( $self->request(GET $url) );

    croak "Request 'watching' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    unless( $res->is_authflagged ){
        $self->login($self->request_login($email, $password));
        $res = Net::NicoVideo::Response->new( $self->request(GET $url) );
        croak "Cannot login because specified account is something wrong"
            unless( $res->is_authflagged );
    }

    return $res;
}

sub request_get {
    my ($self, $url, @args) = @_;
    my $res = Net::NicoVideo::Response->new( $self->request((GET $url), @args) );

    croak "Request 'GET $url' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    return $res;
}

1;
__END__


=pod

=head1 NAME

Net::NicoVideo::UserAgent - Decorate LWP::UserAgent with requests to access to Nico Nico Douga

=head1 SYNOPSIS

    use LWP::UserAgent;
    use Net::NicoVideo::UserAgent;
    
    my $ua = Net::NicoVideo::UserAgent->new(
        LWP::UserAgent->new # or other custom UA by your own needs
        );

    # $flv is a Net::NicoVideo::Response::Flv
    my $flv = $ua->request_flv("smNNNNNNNN");

    # Net::NicoVideo::Response is decorated with HTTP::Response
    $flv->is_success

=head1 DESCRIPTION

Decorate LWP::UserAgent with requests to access to Nico Nico Douga.

=head1 SEE ALSO

L<Net::NicoVideo::Decorator>
L<Net::NicoVideo::Response>

=head1 AUTHOR

WATANABE Hiroaki E<lt>hwat@mac.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
