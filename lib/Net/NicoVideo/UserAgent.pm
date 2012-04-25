package Net::NicoVideo::UserAgent;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_18';

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

sub request_get {
    my ($self, $url, @args) = @_;
    Net::NicoVideo::Response->new( $self->request((GET $url), @args) );
}

#-----------------------------------------------------------
# fetch
# 

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

sub request_thread {
    my $self    = shift;
    my $flv     = shift;
    my $opts    = shift || {};
    require Net::NicoVideo::Response::Thread;
    Net::NicoVideo::Response::Thread->new( $self->request(POST $flv->ms,
        Content => sprintf '<thread thread="%s" version="20061206" res_from="-%d"%s></thread>',
                    $flv->thread_id, ($opts->{'chats'} || 250), ($opts->{'fork'} ? ' fork="1"' : '') ));
}

#-----------------------------------------------------------
# Mylist RSS
# 

sub request_mylistrss {
    my ($self, $mylist) = @_; # mylist or mylist_id
    if( ref($mylist) and $mylist->isa('Net::NicoVideo::Content::Mylist')){
        $mylist = $mylist->id;
    }
    my $url = 'http://www.nicovideo.jp/mylist/'.$mylist.'?rss=2.0';
    require Net::NicoVideo::Response::MylistRSS;
    Net::NicoVideo::Response::MylistRSS->new( $self->request(GET $url) );
}

#-----------------------------------------------------------
# Mylist Base
# 

# taking NicoAPI.token
sub request_mylistpage {
    my $self = shift;
    my $url = 'http://www.nicovideo.jp/my/mylist';
    require Net::NicoVideo::Response::MylistPage;
    Net::NicoVideo::Response::MylistPage->new($self->request(GET $url));
}

# taking NicoAPI.token to update Mylist, item_type and item_id for video_id
sub request_mylistitem {
    my ($self, $video_id) = @_;
    my $url = 'http://www.nicovideo.jp/mylist_add/video/'.$video_id;
    require Net::NicoVideo::Response::MylistItem;
    Net::NicoVideo::Response::MylistItem->new($self->request(GET $url));
}

#-----------------------------------------------------------
# NicoAPI.MylistGroup
# 

# NicoAPI.MylistGroup #list or #get
sub request_mylistgroup {
    my ($self, $mylist) = @_; # mylist or mylist_id (group_id)
    my $url = 'http://www.nicovideo.jp/api/mylistgroup/list';
    my $params;
    if( defined $mylist ){
        $mylist = $mylist->id if( ref($mylist) and $mylist->isa('Net::NicoVideo::Content::NicoAPI::MylistGroup'));
        $url = 'http://www.nicovideo.jp/api/mylistgroup/get';
        $params = [ group_id => $mylist ];
    }
    require Net::NicoVideo::Response::NicoAPI;
    Net::NicoVideo::Response::NicoAPI->new(
        $self->request(POST $url, $params));
}

# NicoAPI.MylistGroup #add
sub request_mylistgroup_add {
    my ($self, $mylist, $token) = @_; # mylist
    my $url = 'http://www.nicovideo.jp/api/mylistgroup/add';
    my $params = [
        token       => $token,
        name        => $mylist->name,
        description => $mylist->description,
        public      => $mylist->public,
        default_sort=> $mylist->default_sort,
        icon_id     => $mylist->icon_id,
        ];
    require Net::NicoVideo::Response::NicoAPI;
    Net::NicoVideo::Response::NicoAPI->new(
        $self->request(POST $url, $params));
}

# NicoAPI.MylistGroup #update
sub request_mylistgroup_update {
    my ($self, $mylist, $token) = @_; # mylist or mylist_id (group_id)
    my $url = 'http://www.nicovideo.jp/api/mylistgroup/update';
    my $params = [
        token       => $token,
        group_id    => $mylist->id,
        name        => $mylist->name,
        description => $mylist->description,
        public      => $mylist->public,
        default_sort=> $mylist->default_sort,
        icon_id     => $mylist->icon_id,
        ];
    require Net::NicoVideo::Response::NicoAPI;
    Net::NicoVideo::Response::NicoAPI->new(
        $self->request(POST $url, $params));
}

# NicoAPI.MylistGroup #remove
sub request_mylistgroup_remove {
    my ($self, $mylist, $token) = @_; # mylist or mylist_id (group_id)
    my $url = 'http://www.nicovideo.jp/api/mylistgroup/delete';
    my $params = [
        token       => $token,
        group_id    => $mylist->id,
        ];
    require Net::NicoVideo::Response::NicoAPI;
    Net::NicoVideo::Response::NicoAPI->new(
        $self->request(POST $url, $params));
}

#-----------------------------------------------------------
# NicoAPI.Mylist
# 

sub make_id_list {
    my $self        = shift;
    my $item_type   = shift;
    my $item_id     = shift;
    my @id_list = ('id_list['.$item_type.'][]' => $item_id);
    return wantarray ? @id_list : \@id_list;
}

# NicoAPI.Mylist #list
sub request_mylist_list {
    my ($self, $mylist) = @_; # mylist or mylist_id (group_id)
    $mylist = $mylist->id if( ref($mylist) and $mylist->isa('Net::NicoVideo::Content::NicoAPI::MylistGroup'));
    my $url = 'http://www.nicovideo.jp/api/mylist/list';
    require Net::NicoVideo::Response::NicoAPI;
    Net::NicoVideo::Response::NicoAPI->new(
        $self->request(POST $url, [group_id => $mylist]));
}

# NicoAPI.Mylist #add
sub request_mylist_add {
    my ($self, $mylist, $item, $token) = @_; # mylist or mylist_id (group_id)
    $mylist = $mylist->id if( ref($mylist) and $mylist->isa('Net::NicoVideo::Content::NicoAPI::MylistGroup'));
    my $url = 'http://www.nicovideo.jp/api/mylist/add';
    my $params = [
        token       => $token,
        group_id    => $mylist,
        item_type   => $item->item_type,
        item_id     => $item->item_id,
        description => $item->description,
        ];
    require Net::NicoVideo::Response::NicoAPI;
    Net::NicoVideo::Response::NicoAPI->new(
        $self->request(POST $url, $params));
}

# NicoAPI.Mylist #update
sub request_mylist_update {
    my ($self, $mylist, $item, $token) = @_; # mylist or mylist_id (group_id)
    $mylist = $mylist->id if( ref($mylist) and $mylist->isa('Net::NicoVideo::Content::NicoAPI::MylistGroup'));
    my $url = 'http://www.nicovideo.jp/api/mylist/update';
    my $params = [
        token       => $token,
        group_id    => $mylist,
        item_type   => $item->item_type,
        item_id     => $item->item_id,
        description => $item->description,
        ];
    require Net::NicoVideo::Response::NicoAPI;
    Net::NicoVideo::Response::NicoAPI->new(
        $self->request(POST $url, $params));
}

# NicoAPI.Mylist #remove
sub request_mylist_remove {
    my ($self, $mylist, $item, $token) = @_; # mylist or mylist_id (group_id)
    my $id_list = $self->make_id_list($item->item_type, $item->item_id);
    $self->request_mylist_remove_multi($mylist, $id_list, $token);
}

# NicoAPI.Mylist #removeMulti
sub request_mylist_remove_multi {
    my ($self, $mylist, $id_list, $token) = @_; # mylist or mylist_id (group_id)
    $mylist = $mylist->id if( ref($mylist) and $mylist->isa('Net::NicoVideo::Content::NicoAPI::MylistGroup'));
    my $url = 'http://www.nicovideo.jp/api/mylist/delete';
    my $params = $id_list;
    push @$params, (
        token       => $token,
        group_id    => $mylist,
        );
    require Net::NicoVideo::Response::NicoAPI;
    Net::NicoVideo::Response::NicoAPI->new(
        $self->request(POST $url, $params));
}

# NicoAPI.Mylist #move
sub request_mylist_move {
    my ($self, $mylist, $target, $item, $token) = @_; # mylist or mylist_id (group_id)
    my $id_list = $self->make_id_list($item->item_type, $item->item_id);
    $self->request_mylist_move_multi($mylist, $target, $id_list, $token);
}

# NicoAPI.Mylist #moveMulti
sub request_mylist_move_multi {
    my ($self, $mylist, $target, $id_list, $token) = @_; # mylist or mylist_id (group_id)
    $mylist = $mylist->id if( ref($mylist) and $mylist->isa('Net::NicoVideo::Content::NicoAPI::MylistGroup'));
    $target = $target->id if( ref($target) and $target->isa('Net::NicoVideo::Content::NicoAPI::MylistGroup'));
    my $url = 'http://www.nicovideo.jp/api/mylist/move';
    my $params = $id_list;
    push @$params, (
        token           => $token,
        group_id        => $mylist,
        target_group_id => $target,
        );
    require Net::NicoVideo::Response::NicoAPI;
    Net::NicoVideo::Response::NicoAPI->new(
        $self->request(POST $url, $params));
}

# NicoAPI.Mylist #copy
sub request_mylist_copy {
    my ($self, $mylist, $target, $item, $token) = @_; # mylist or mylist_id (group_id)
    my $id_list = $self->make_id_list($item->item_type, $item->item_id);
    $self->request_mylist_copy_multi($mylist, $target, $id_list, $token);
}

# NicoAPI.Mylist #copyMulti
sub request_mylist_copy_multi {
    my ($self, $mylist, $target, $id_list, $token) = @_; # mylist or mylist_id (group_id)
    $mylist = $mylist->id if( ref($mylist) and $mylist->isa('Net::NicoVideo::Content::NicoAPI::MylistGroup'));
    $target = $target->id if( ref($target) and $target->isa('Net::NicoVideo::Content::NicoAPI::MylistGroup'));
    my $url = 'http://www.nicovideo.jp/api/mylist/copy';
    my $params = $id_list;
    push @$params, (
        token           => $token,
        group_id        => $mylist,
        target_group_id => $target,
        );
    require Net::NicoVideo::Response::NicoAPI;
    Net::NicoVideo::Response::NicoAPI->new(
        $self->request(POST $url, $params));
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
