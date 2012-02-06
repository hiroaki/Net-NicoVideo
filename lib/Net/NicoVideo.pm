package Net::NicoVideo;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_06';

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

Net::NicoVideo - Wrapping API of Nico Nico Douga

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

Net::NicoVideo provides methods accessing API of Nico Nico Douga.
Each methods return the data capsule class which stored the result of having parsed the response.
Please see these classes for detail,
L<Net::NicoVideo::Flv>, L<Net::NicoVideo::ThumbInfo> and L<Net::NicoVideo::Watch>.

Note that this class is the utility that uses actually accessing to API.
Therefore we can also use L<Net::NicoVideo::UserAgent> to tackle the low level problems.

=head1 ENVIRONMENT VARIABLE

    NET_NICOVIDEO_EMAIL
    NET_NICOVIDEO_PASSWORD

These obvious environment variables are effective. 
If the object has each value as its members, priority is given to them.

=head2 FOR BUSY PERSON

You can download video by one liner:

    $ export NET_NICOVIDEO_EMAIL=your-nicovideo@email.address
    $ export NET_NICOVIDEO_PASSWORD=and-password
    $ perl -MNet::NicoVideo -e 'Net::NicoVideo->new->download("smNNNNNN", "./smile.mp4")'

=head1 SEE ALSO

L<Net::NicoVideo::Flv>
L<Net::NicoVideo::ThumbInfo>
L<Net::NicoVideo::Watch>

=head1 AUTHOR

WATANABE Hiroaki E<lt>hwat@mac.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
