package Net::NicoVideo;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_02';

use base qw(Class::Accessor::Fast);
use Carp qw(croak);
use HTTP::Cookies;
use HTTP::Request::Common;
use Net::NicoVideo::Response::Flv;
use Net::NicoVideo::Response::ThumbInfo;
use LWP::UserAgent;

use vars qw($AgentName $DelayDefault);
$AgentName = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.50 (KHTML, like Gecko) Version/5.1 Safari/534.50';
$DelayDefault = 3;

__PACKAGE__->mk_accessors(qw(
user_agent
username
password
delay
));

sub is_logged_in {
    my ($self, $res) = @_;
    $res->headers->header('x-niconico-authflag');
}

sub ua {
    my $self = shift;
    unless( $self->user_agent ){
        $self->user_agent(
            LWP::UserAgent->new(
                agent => $AgentName,
                ));
    }
    return $self->user_agent;
}

sub login_ua {
    my $self = shift;
    my $ua = $self->ua;

    my $res = $ua->request(POST 'https://secure.nicovideo.jp/secure/login?site=niconico', [
        next_url => '',
        mail => $self->{username},
        password => $self->{password},
        ]);
    
    my $cookie_jar = HTTP::Cookies->new;
    $cookie_jar->extract_cookies($res);
    $ua->cookie_jar($cookie_jar);

    return $self->user_agent($ua);
}

sub fetch_thumbinfo {
    my $self = shift;
    my $video_id = shift or croak "missing mandatory parameter 'video_id'";
    my $url = sprintf 'http://ext.nicovideo.jp/api/getthumbinfo/%s', $video_id;
    Net::NicoVideo::Response::ThumbInfo->new( $self->ua->request(GET $url) );
}

sub fetch_flv {
    my $self = shift;
    my $video_id = shift or croak "missing mandatory parameter 'video_id'";
    my $url = 'http://flapi.nicovideo.jp/api/getflv/'.$video_id;

    my $params = [];
    if( $video_id =~ /^nm/ ){
        push @$params, ('as3' => 1);
    }
    
    my $res = $self->ua->request(POST $url, $params);
    unless( $self->is_logged_in( $res ) ){
        $res = $self->login_ua->request(POST $url, $params );
    }
    Net::NicoVideo::Response::Flv->new( $res );
}

sub watch_page {
    my $self = shift;
    my $video_id = shift or croak "missing mandatory parameter 'video_id'";
    my $url = sprintf 'http://www.nicovideo.jp/watch/%s', $video_id;

    my $res = $self->ua->request(GET $url);
    unless( $self->is_logged_in( $res ) ){
        $res = $self->login_ua->request(GET $url);
    }
    Net::NicoVideo::Response->new( $res );
}

sub mirror_video {
    my $self = shift;
    my $video_url = shift or croak "missing mandatory parameter 'video_url'";
    my $save_path = shift or croak "missing mandatory parameter 'save_path'";
    $self->ua->mirror( $video_url, $save_path );
}

sub get_thumbinfo {
    my $self = shift;
    my $video_id = shift or croak "missing mandatory parameter 'video_id'";
    my $res = $self->fetch_thumbinfo($video_id);

    die "response is not success: @{[ $res->status_line ]}\n"
        unless( $res->is_success );
    
    die "content is invalid: @{[ $res->content ]}\n"
        unless( $res->is_content_success );

    return $res->parsed_content; # Net::NicoVideo::ThumbInfo
}

sub get_flv {
    my $self = shift;
    my $video_id = shift or croak "missing mandatory parameter 'video_id'";
    my $res = $self->fetch_flv($video_id);
    
    die "response is not success: @{[ $res->status_line ]}\n"
        unless( $res->is_success );
    
    die "content is invalid: @{[ $res->content ]}\n"
        unless( $res->is_content_success );

    return $res->parsed_content; # Net::NicoVideo::Flv
}

1;
__END__

=head1 NAME

Net::NicoVideo - Perl library wrapping API of "nicovideo"

=head1 SYNOPSIS

    use 5.12.0;
    use warnings;
    use Net::NicoVideo;
    
    my $video_id = $ARGV[0] or die;
    
    my $nnv = Net::NicoVideo->new({
        username => 'your-nicovideo@email.address',
        password => 'and-password',
        });
    
    my $info = $nnv->get_thumbinfo( $video_id );
    my $flv  = $nnv->get_flv( $video_id );
    
    
    say "downloading: ". $info->title;
    if( $flv->is_economy ){
        say "now economy time, skip";
    }else{
        my $path = sprintf '%s/Movies/%s.%s',
                    $ENV{HOME}, $video_id, $info->movie_type;
    
        $nnv->watch_page( $video_id );
        sleep 2;
        $nnv->mirror_video( $flv->url, $path );
    }

=head1 DESCRIPTION

Net::NicoVideo is wrapping web API of "nicovideo".

This provides accessing methods for each object "thumbinfo" and "flv".

=head1 AUTHOR

Author E<lt>hwat@mac.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Net::NicoVideo::Flv>
L<Net::NicoVideo::ThumbInfo>

=cut
