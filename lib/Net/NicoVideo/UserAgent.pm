package Net::NicoVideo::UserAgent;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_14';

use base qw(Net::NicoVideo::Decorator);

use HTTP::Cookies;
use HTTP::Request::Common;
use Net::NicoVideo::Response;

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
    require Net::NicoVideo::Response::ThumbInfo;
    Net::NicoVideo::Response::ThumbInfo->new( $self->request(GET $url) );
}

sub request_flv {
    my ($self, $video_id) = @_;
    my $url = 'http://flapi.nicovideo.jp/api/getflv/'.$video_id;
    my $params = $video_id =~ /^nm/ ? ['as3' => 1] : [];
    require Net::NicoVideo::Response::Flv;
    Net::NicoVideo::Response::Flv->new( $self->request(POST $url, $params) );
}

sub request_thread {
    my $self    = shift;
    my $flv     = shift;
    my $opts    = shift || {};
    require Net::NicoVideo::Response::Thread;
    Net::NicoVideo::Response::Thread->new( $self->request(POST $flv->ms,
        Content => sprintf '<thread thread="%s" version="20061206" res_from="-%d"%s></thread>',
                    $flv->thread_id, ($opts->{'chats'} || 250), ($opts->{'fork'} ? ' fork="1"' : '') ));
}

sub request_watch {
    my ($self, $video_id) = @_;
    my $url = 'http://www.nicovideo.jp/watch/'.$video_id;
    require Net::NicoVideo::Response::Watch;
    Net::NicoVideo::Response::Watch->new( $self->request(GET $url) );
}

sub request_video {
    my ($self, $flv, @args) = @_;
    my $url = ( ref $flv ) ? $flv->url : $flv;
    require Net::NicoVideo::Response::Video;
    Net::NicoVideo::Response::Video->new( $self->request((GET $url), @args) );
}

sub request_mylistrss {
    my ($self, $mylist) = @_; # mylist or mylist_id
    if( ref($mylist) and $mylist->isa('Net::NicoVideo::Content::Mylist')){
        $mylist = $mylist->id;
    }
    my $url = 'http://www.nicovideo.jp/mylist/'.$mylist.'?rss=2.0';
    require Net::NicoVideo::Response::MylistRSS;
    Net::NicoVideo::Response::MylistRSS->new( $self->request(GET $url) );
}

sub request_mylistgroup { # for user own
    my ($self) = @_;
    my $url = 'http://www.nicovideo.jp/api/mylistgroup/list';
    require Net::NicoVideo::Response::MylistGroup;
    Net::NicoVideo::Response::MylistGroup->new( $self->request(GET $url) );
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
