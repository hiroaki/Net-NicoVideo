package Net::NicoVideo;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_04';

use base qw(Class::Accessor::Fast);
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
    $self->get_user_agent->request_thumbinfo($video_id)->parsed_content;
}

sub fetch_flv {
    my ($self, $video_id) = @_;
    $self->get_user_agent->request_flv($video_id, $self->get_email, $self->get_password)->parsed_content;
}

sub watch_video {
    my ($self, $video_id) = @_;
    $self->get_user_agent->request_watching($video_id, $self->get_email, $self->get_password);
}

sub fetch_video {
    my ($self, $flv, @args) = @_;
    $self->get_user_agent->request_get($flv->url, @args);
}

sub download {
    my ($self, $video_id, @args) = @_;
    $self->get_user_agent->request_watching($video_id);
    sleep (defined $self->delay ? $self->delay : $DelayDefault);
    $self->fetch_video($self->fetch_flv($video_id), @args);
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

This provides methods that accessing API of Nico Nico Douga
via each object Net::NicoVideo::ThumbInfo and Net::NicoVideo::Flv.
Please see these classes for detail.

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

=head1 AUTHOR

WATANABE Hiroaki E<lt>hwat@mac.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
