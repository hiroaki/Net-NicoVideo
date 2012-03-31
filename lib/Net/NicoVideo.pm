package Net::NicoVideo;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_08';

use base qw(Class::Accessor::Fast);

use Carp qw(croak);
use LWP::UserAgent;
use Net::NicoVideo::UserAgent;

use vars qw($DelayDefault);
$DelayDefault = 1;

__PACKAGE__->mk_accessors(qw(
user_agent
email
password
delay
));

sub get_user_agent {
    my $self = shift;
    
    $self->user_agent(LWP::UserAgent->new)
        unless( $self->user_agent );

    Net::NicoVideo::UserAgent->new($self->user_agent);
}

sub get_email {
    my $self = shift;
    return defined $self->email ? $self->email : $ENV{NET_NICOVIDEO_EMAIL};
}

sub get_password {
    my $self = shift;
    return defined $self->password ? $self->password : $ENV{NET_NICOVIDEO_PASSWORD};
}

sub fetch_thumbinfo {
    my ($self, $video_id) = @_;
    my $res = $self->get_user_agent->request_thumbinfo($video_id);

    croak "Request 'request_thumbinfo' is error: @{[ $res->status_line ]}"
        if( $res->is_error );
    
    croak "Invalid content as 'thumbinfo'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

sub fetch_flv {
    my ($self, $video_id) = @_;
    my $ua  = $self->get_user_agent;
    my $res = $ua->request_flv($video_id);

    croak "Request 'request_flv' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    unless( $res->is_authflagged ){
    
        my $reslogin = $ua->request_login($self->get_email, $self->get_password);
        croak "Request 'request_login' is error: @{[ $reslogin->status_line ]}"
            if( $reslogin->is_error );

        $ua->login( $reslogin );

        # try again
        $res = $ua->request_flv($video_id);
        croak "Cannot login because specified account is something wrong"
            unless( $res->is_authflagged );
    }

    croak "Invalid content as 'flv'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

sub fetch_mylist {
    my ($self, $mylist_id) = @_;
    my $res = $self->get_user_agent->request_mylist($mylist_id);

    croak "Request 'request_mylist' is error: @{[ $res->status_line ]}"
        if( $res->is_error );
    
    croak "Invalid content as 'mylist'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

sub watch_video {
    my ($self, $video_id) = @_;
    my $ua  = $self->get_user_agent;
    my $res = $ua->request_watch($video_id);

    croak "Request 'request_watch' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    unless( $res->is_authflagged ){

        my $reslogin = $ua->request_login($self->get_email, $self->get_password);
        croak "Request 'request_login' is error: @{[ $reslogin->status_line ]}"
            if( $reslogin->is_error );

        $ua->login( $reslogin );

        # try again
        $res = $ua->request_watch($video_id);
        croak "Cannot login because specified account is something wrong"
            unless( $res->is_authflagged );
    }

    croak "Invalid content as 'watch'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

sub fetch_video {
    my ($self, $flv, @args) = @_;
    
    my $res = $self->get_user_agent->request_video($flv, @args);
    croak "Request 'fetch_video' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    croak "Invalid content as 'video'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

sub download {
    my ($self, $video_id, @args) = @_;
    $self->watch_video($video_id);
    my $delay = defined($self->delay) ? $self->delay : $DelayDefault;
    sleep $delay if( $delay );
    $self->fetch_video($self->fetch_flv($video_id), @args);
    return $self;
}

1;
__END__


=pod

=head1 NAME

Net::NicoVideo - Perl Interface for accessing Nico Nico Douga

=head1 SYNOPSIS

    use Net::NicoVideo;

    my $video_id = $ARGV[0] or die;

    my $nnv = Net::NicoVideo->new({
        email    => 'your-nicovideo@email.address',
        password => 'and-password',
        });

    my $info = $nnv->fetch_thumbinfo( $video_id );
    my $flv  = $nnv->fetch_flv( $video_id );

    printf "download: %s\n". $info->title;
    if( $flv->is_economy ){
        warn "now economy time, skip\n";
    }else{
        my $save_path = sprintf '%s/Movies/%s.%s',
            $ENV{HOME}, $video_id, $info->movie_type;
    
        $nnv->watch_video( $video_id );
        $nnv->fetch_video( $flv, $save_path );
    }

=head1 DESCRIPTION

Nico Nico Douga (ニコニコ動画, lit. "Smile Videos") is a popular video sharing website
in Japan managed by Niwango, a subsidiary of Dwango.

A Distribution Net-NicoVideo is Perl Interface for accessing Nico Nico Douga.
This provides the consistent access method,
and contents are encapsulated and give facilities to clients.

Net::NicoVideo, instance of this class, is an utility
that actually uses agent Net::NicoVideo::UserAgent.
Therefore we can also use Net::NicoVideo::UserAgent to tackle the low level problems.

=head1 CONSTRUCTOR

TODO

=head1 ACCESS METHOD

=head2 user_agent

TODO

=head2 email

TODO

=head2 password

TODO

=head2 delay

TODO

=head2 get_user_agent

Create an instance of Net::NicoVideo::UserAgent.

=head2 get_email

Get email that instance has.
If it is not defined, $ENV{NET_NICOVIDEO_EMAIL} is returned instead.

=head2 get_password

Get password that the instance has.
If it is not defined, $ENV{NET_NICOVIDEO_PASSWORD} is returned instead.

=head1 FETCH METHOD

Each methods return Net::NicoVideo::Content class which stored the result of having parsed the response.
Please see sub classes under Net::NicoVideo::Content for detail.

=head2 fetch_thumbinfo(video_id)

Get an instance of Net::NicoVideo::Content::ThumbInfo for video_id.

=head2 fetch_flv(video_id)

Get an instance of Net::NicoVideo::Content::Flv for video_id.

=head2 fetch_mylist

Get an instance of Net::NicoVideo::Content::Mylist for video_id.

=head2 watch_video(video_id)

Get an instance of Net::NicoVideo::Content::Watch for video_id.

This means that the agent watches the video, and this behavior is required before fetch_video.

=head2 fetch_video(Net::NicoVideo::Content::Flv, @args)

Get an instance of Net::NicoVideo::Content::Video for video_id
taht is included Net::NicoVideo::Content::Flv object.

This method works like as request() method of LWP::UserAgent, in fact, it is called.

=head1 UTILITY METHOD

=head2 download(video_id, file)

This is a shortcut to download video that is identified by video_id.

For busy person, you can download a video by one liner like this:

    $ perl -MNet::NicoVideo -e 'Net::NicoVideo->new->download(@ARGV)' smNNNNNN ./smile.mp4

Note that it is necessary to set environment variables in advance.

=head1 ENVIRONMENT VARIABLE

    NET_NICOVIDEO_EMAIL
    NET_NICOVIDEO_PASSWORD

These obvious environment variables are effective. 
If the object has each value as its members, priority is given to them.

=head1 SEE ALSO

L<Net::NicoVideo::Content>
L<Net::NicoVideo::UserAgent>

=head1 AUTHOR

WATANABE Hiroaki E<lt>hwat@mac.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
