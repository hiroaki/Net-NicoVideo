package Net::NicoVideo::UserAgent;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_06';

use base qw(Net::NicoVideo::Decorator);

use HTTP::Cookies;
use HTTP::Request::Common;
use Net::NicoVideo::Response;
use Net::NicoVideo::Response::Flv;
use Net::NicoVideo::Response::ThumbInfo;
use Net::NicoVideo::Response::Video;
use Net::NicoVideo::Response::Watch;

sub new {
    my ($class, $component, @opts) = @_;

    # component accepts LWP::UserAgent
    $class->SUPER::new($component, @opts);
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
    Net::NicoVideo::Response->new(
                $self->request(POST $url, [
                    next_url    => '',
                    mail        => $email,
                    password    => $password,
                    ]));
}

sub request_thumbinfo {
    my ($self, $video_id) = @_;
    my $url = 'http://ext.nicovideo.jp/api/getthumbinfo/'.$video_id;
    Net::NicoVideo::Response::ThumbInfo->new( $self->request(GET $url) );
}

sub request_flv {
    my ($self, $video_id) = @_;
    my $url = 'http://flapi.nicovideo.jp/api/getflv/'.$video_id;
    my $params = $video_id =~ /^nm/ ? ['as3' => 1] : [];
    Net::NicoVideo::Response::Flv->new( $self->request(POST $url, $params) );
}

sub request_watching {
    my $self = shift;
    warn "DEPRECATED WARNING: request_watching will removed future release, please use request_watch instead";
    $self->request_watch(@_);
}

sub request_watch {
    my ($self, $video_id) = @_;
    my $url = 'http://www.nicovideo.jp/watch/'.$video_id;
    Net::NicoVideo::Response::Watch->new( $self->request(GET $url) );
}

sub request_video {
    my ($self, $flv, @args) = @_;
    my $url = ( ref $flv ) ? $flv->url : $flv;
    Net::NicoVideo::Response::Video->new( $self->request((GET $url), @args) );
}

sub request_get {
    my ($self, $url, @args) = @_;
    Net::NicoVideo::Response->new( $self->request((GET $url), @args) );
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
