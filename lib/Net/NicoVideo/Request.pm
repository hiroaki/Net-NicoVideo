package Net::NicoVideo::Request;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_19';

use base qw(HTTP::Request);
use HTTP::Request::Common;
use Carp qw/croak/;

sub get {
    my $class = shift;
    return GET @_;
}

sub login {
    my $class = shift;
    my $email = shift or croak "missing mandatory parameter";
    my $password = shift or croak "missing mandatory parameter";
    my $url = 'https://secure.nicovideo.jp/secure/login?site=niconico';
    return POST $url, [
        next_url    => '',
        mail        => $email,
        password    => $password,
        ];
}

sub thumbinfo {
    my $class = shift;
    my $video_id = shift or croak "missing mandatory parameter";
    my $url = 'http://ext.nicovideo.jp/api/getthumbinfo/'.$video_id;
    return GET $url;
}

sub flv {
    my $class = shift;
    my $video_id = shift or croak "missing mandatory parameter";
    my $url = 'http://flapi.nicovideo.jp/api/getflv/'.$video_id;
    my $params = $video_id =~ /^nm/ ? ['as3' => 1] : [];
    return POST $url, $params;
}

sub watch {
    my $class = shift;
    my $video_id = shift or croak "missing mandatory parameter";
    my $url = 'http://www.nicovideo.jp/watch/'.$video_id;
    return GET $url;
}

sub thread {
    my $class = shift;
    my $ms = shift or croak "missing mandatory parameter";
    my $thread_id = shift or croak "missing mandatory parameter";
    my $opts = shift || {};
    return POST $ms,
        Content => sprintf '<thread thread="%s" version="20061206" res_from="-%d"%s></thread>',
            $thread_id, ($opts->{'chats'} || 250), ($opts->{'fork'} ? ' fork="1"' : '');    
}

sub mylist_rss {
    my $class = shift;
    my $mylist_id = shift or croak "missing mandatory parameter";;
    my $url = 'http://www.nicovideo.jp/mylist/'.$mylist_id.'?rss=2.0';
    return GET $url;
}

sub mylist_page {
    my $class = shift;
    return GET 'http://www.nicovideo.jp/my/mylist';
}

sub mylist_item {
    my $class = shift;
    my $video_id = shift or croak "missing mandatory parameter";
    my $url = 'http://www.nicovideo.jp/mylist_add/video/'.$video_id;
    return GET $url;
}

sub mylistgroup_list {
    my $class = shift;
    return POST 'http://www.nicovideo.jp/api/mylistgroup/list';
}

sub mylistgroup_get {
    my $class = shift;
    my $mylist_id = shift or croak "missing mandatory parameter";
    my $params = [ group_id => $mylist_id ];
    return POST 'http://www.nicovideo.jp/api/mylistgroup/get', $params;
}

sub mylistgroup_add {
    my $class = shift;
    my $params = shift || {};
    my $token = shift;
    return POST 'http://www.nicovideo.jp/api/mylistgroup/add', [
        token       => $token,
        name        => $params->{name},
        description => $params->{description},
        public      => $params->{public},
        default_sort=> $params->{default_sort},
        icon_id     => $params->{icon_id},
        ];
}

sub mylistgroup_update {
    my $class = shift;
    my $params = shift || {};
    my $token = shift;
    return POST 'http://www.nicovideo.jp/api/mylistgroup/update', [
        token       => $token,
        group_id    => $params->{group_id},
        name        => $params->{name},
        description => $params->{description},
        public      => $params->{public},
        default_sort=> $params->{default_sort},
        icon_id     => $params->{icon_id},
        ];
}

sub mylistgroup_delete {
    my $class = shift;
    my $params = shift || {};
    my $token = shift;
    return POST 'http://www.nicovideo.jp/api/mylistgroup/delete', [
        token       => $token,
        group_id    => $params->{group_id},
        ];
}

sub mylist_list {
    my $class = shift;
    my $group_id = shift or croak "missing mandatory parameter";
    my $params = [ group_id => $group_id ];
    return POST 'http://www.nicovideo.jp/api/mylist/list', $params;
}

sub mylist_add {
    my $class = shift;
    my $params = shift || {};
    my $token = shift;
    return POST 'http://www.nicovideo.jp/api/mylist/add', [
        token       => $token,
        group_id    => $params->{group_id},
        item_type   => $params->{item_type},
        item_id     => $params->{item_id},
        description => $params->{description},
        ];
}

sub mylist_update {
    my $class = shift;
    my $params = shift || {};
    my $token = shift;
    return POST 'http://www.nicovideo.jp/api/mylist/update', [
        token       => $token,
        group_id    => $params->{group_id},
        item_type   => $params->{item_type},
        item_id     => $params->{item_id},
        description => $params->{description},
        ];
}

sub mylist_delete {
    my $class = shift;
    my $params = shift || {};
    my $token = shift;
    my @args = $class->make_id_list($params->{item_type}, $params->{item_id});
    push @args, (
        token       => $token,
        group_id    => $params->{group_id},
        );
    return POST 'http://www.nicovideo.jp/api/mylist/delete', \@args;
}

sub mylist_move {
    my $class = shift;
    my $params = shift || {};
    my $token = shift;
    my @args = $class->make_id_list($params->{item_type}, $params->{item_id});
    push @args, (
        token           => $token,
        group_id        => $params->{group_id},
        target_group_id => $params->{target_group_id},
        );
    return POST 'http://www.nicovideo.jp/api/mylist/move', \@args;
}

sub mylist_copy {
    my $class = shift;
    my $params = shift || {};
    my $token = shift;
    my @args = $class->make_id_list($params->{item_type}, $params->{item_id});
    push @args, (
        token           => $token,
        group_id        => $params->{group_id},
        target_group_id => $params->{target_group_id},
        );
    return POST 'http://www.nicovideo.jp/api/mylist/copy', \@args;
}


sub make_id_list {
    my $class = shift;
    my $item_type = shift;
    my $item_id = shift;
    croak "missing mandatory parameter" unless( defined $item_type );
    croak "missing mandatory parameter" unless( defined $item_id );
    my @id_list = ('id_list['.$item_type.'][]' => $item_id);
    return wantarray ? @id_list : \@id_list;
}

1;
__END__
