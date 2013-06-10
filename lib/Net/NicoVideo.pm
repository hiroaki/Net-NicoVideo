package Net::NicoVideo;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_25';

use base qw(Class::Accessor::Fast);

use Carp qw(croak);
use LWP::UserAgent;
use Net::NicoVideo::UserAgent;

use vars qw($DELAY_DEFAULT);
$DELAY_DEFAULT = 1;

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

sub get_delay {
    my $self = shift;
    if( defined $self->delay ){
        return $self->delay;
    }elsif( $ENV{NET_NICOVIDEO_DELAY} ){
        return $ENV{NET_NICOVIDEO_DELAY};
    }else{
        return $DELAY_DEFAULT;
    }
}

sub through_login {
    my $self    = shift;
    my $ua      = shift;
    my $res     = $ua->request_login($self->get_email, $self->get_password);
    croak "Request 'request_login' is error: @{[ $res->status_line ]}"
        if( $res->is_error );
    $ua->login( $res ); # this returns $ua
}

sub download {
    my ($self, $video_id, @args) = @_;
    $self->fetch_watch($video_id);
    my $delay = defined($self->delay) ? $self->delay : $DELAY_DEFAULT;
    sleep $delay if( $delay );
    $self->fetch_video($self->fetch_flv($video_id), @args);
    return $self;
}

#-----------------------------------------------------------
# fetch
# 

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
    
    # workaround
    if( $video_id and $video_id =~ /^so\d+$/ ){
        my $item = $self->fetch_mylist_item($video_id);
        $video_id = $item->item_id;
    }
    my $res = $ua->request_flv($video_id);

    croak "Request 'request_flv' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    unless( $res->is_authflagged ){
        # try again
        $res = $self->through_login($ua)->request_flv($video_id);
        croak "Cannot login because specified account is something wrong"
            unless( $res->is_authflagged );
    }

    croak "Invalid content as 'flv'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

sub fetch_watch {
    my ($self, $video_id) = @_;
    my $ua  = $self->get_user_agent;
    my $res = $ua->request_watch($video_id);

    croak "Request 'request_watch' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    unless( $res->is_authflagged ){
        # try again
        $res = $self->through_login($ua)->request_watch($video_id);
        croak "Cannot login because specified account is something wrong"
            unless( $res->is_authflagged );
    }

    croak "Invalid content as 'watch'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

sub fetch_video {
    # $something accepts flv, url ( via flv->url ) or video_id
    my ($self, $something, @args) = @_;
    if( $something and ! ref($something) and $something !~ m{^https?://} ){
        # it is a video_id
        $something = $self->fetch_flv($something);
    }
    my $res = $self->get_user_agent->request_video($something, @args);
    croak "Request 'fetch_video' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    croak "Invalid content as 'video'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

sub fetch_thread {
    # $something accepts flv, or video_id
    my ($self, $something, $opts) = @_;
    if( $something and ! ref($something) ){
        # it is a video_id
        $something = $self->fetch_flv($something);
    }
    my $res = $self->get_user_agent->request_thread($something, $opts);
    croak "Request 'fetch_thread' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    croak "Invalid content as 'thread'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

#-----------------------------------------------------------
# Tag RSS
# 

sub fetch_tag_rss {
    my ($self, $keyword, $params) = @_;
    my $ua  = $self->get_user_agent;
    my $res = $ua->request_tag_rss($keyword, $params);

    croak "Request 'request_tag_rss' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    croak "Invalid content as 'tag'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

sub fetch_tag_rss_by_recent_post { # shortcut
    my ($self, $keyword, $page) = @_;
    $page ||= 1;
    $self->fetch_tag_rss($keyword, {'sort' => 'f', page => $page});
}

#-----------------------------------------------------------
# Mylist RSS
# 

sub fetch_mylist_rss {
    my ($self, $mylist) = @_;
    my $ua  = $self->get_user_agent;
    my $res = $ua->request_mylist_rss($mylist);

    croak "Request 'request_mylist_rss' is error: @{[ $res->status_line ]}"
        if( $res->is_error and $res->code ne '403' );

    if( ( ! $res->is_authflagged or $res->is_closed ) 
     and defined $self->get_email
     and defined $self->get_password
    ){
        # try again
        $res = $self->through_login($ua)->request_mylist_rss($mylist);
        croak "Cannot login because specified account is something wrong"
            unless( $res->is_authflagged );
    }

    croak "Invalid content as 'mylist'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

#-----------------------------------------------------------
# Mylist Base
# 

# taking NicoAPI.token
sub fetch_mylist_page {
    my ($self) = @_;
    my $ua  = $self->get_user_agent;
    my $res = $ua->request_mylist_page;

    croak "Request 'request_mylist_page' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    unless( $res->is_authflagged ){
        # try again
        $res = $self->through_login($ua)->request_mylist_page;
        croak "Cannot login because specified account is something wrong"
            unless( $res->is_authflagged );
    }

    croak "Invalid content as 'mylist_page'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

# taking NicoAPI.token to update Mylist, item_type and item_id for video_id
sub fetch_mylist_item {
    my ($self, $video_id) = @_;
    my $ua  = $self->get_user_agent;
    my $res = $ua->request_mylist_item($video_id);

    croak "Request 'request_mylist_item' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    unless( $res->is_authflagged ){
        # try again
        $res = $self->through_login($ua)->request_mylist_item($video_id);
        croak "Cannot login because specified account is something wrong"
            unless( $res->is_authflagged );
    }

    croak "Invalid content as 'mylist_item'"
        if( $res->is_content_error );

    return $res->parsed_content;
}

#-----------------------------------------------------------
# NicoAPI.MylistGroup
# 

# NicoAPI.MylistGroup #list
sub list_mylistgroup {
    my ($self) = @_;
    my $ua  = $self->get_user_agent;
    my $res = $ua->request_mylistgroup_list;

    croak "Request 'request_mylistgroup_list' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    unless( $res->is_content_success ){
        if( $res->is_error_noauth ){
            # try again
            $res = $self->through_login($ua)->request_mylistgroup_list;
            unless( $res->is_content_success ){
                if( $res->is_error_noauth ){
                    croak "Cannot login because specified account is something wrong";
                }
                croak "Invalid content as 'mylistgroup'";
            }
        }
    }
    
    return $res->parsed_content;
}

# NicoAPI.MylistGroup #get
sub get_mylistgroup {
    my ($self, $group_id) = @_;
    my $ua  = $self->get_user_agent;
    my $res = $ua->request_mylistgroup_get($group_id);

    croak "Request 'request_mylistgroup_get' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    unless( $res->is_content_success ){
        if( $res->is_error_noauth ){
            # try again
            $res = $self->through_login($ua)->request_mylistgroup_get($group_id);
            unless( $res->is_content_success ){
                if( $res->is_error_noauth ){
                    croak "Cannot login because specified account is something wrong";
                }
                croak "Invalid content as 'mylistgroup'";
            }
        }
    }
    
    return $res->parsed_content;
}

# NicoAPI.MylistGroup #add
sub add_mylistgroup {
    my ($self, $mylist, $token) = @_;
    my $ua  = $self->get_user_agent;
    $token = $self->fetch_mylist_page->token
        unless( $token );
    my $res = $ua->request_mylistgroup_add($mylist, $token);
    croak "Request 'request_mylistgroup_add' is error: @{[ $res->status_line ]}"
        if( $res->is_error );
    return $res->parsed_content;
}

# NicoAPI.MylistGroup #update
sub update_mylistgroup {
    my ($self, $mylist, $token) = @_;
    my $ua  = $self->get_user_agent;
    $token = $self->fetch_mylist_page->token
        unless( $token );
    my $res = $ua->request_mylistgroup_update($mylist, $token);
    croak "Request 'request_mylistgroup_update' is error: @{[ $res->status_line ]}"
        if( $res->is_error );
    return $res->parsed_content;
}

# NicoAPI.MylistGroup #remove
sub remove_mylistgroup {
    my ($self, $mylist, $token) = @_;
    my $ua  = $self->get_user_agent;
    $token = $self->fetch_mylist_page->token
        unless( $token );
    my $res = $ua->request_mylistgroup_delete($mylist, $token);
    croak "Request 'request_mylistgroup_delete' is error: @{[ $res->status_line ]}"
        if( $res->is_error );
    return $res->parsed_content;
}

*delete_mylistgroup = *remove_mylistgroup;

#-----------------------------------------------------------
# NicoAPI.Mylist
# 

# NicoAPI.Mylist #list
sub list_mylist {
    my ($self, $group) = @_; # mylistgroup or group_id
    my $ua  = $self->get_user_agent;
    my $res = $ua->request_mylist_list($group);

    croak "Request 'request_mylist_list' is error: @{[ $res->status_line ]}"
        if( $res->is_error );

    unless( $res->is_content_success ){
        if( $res->is_error_noauth ){
            # try again
            $res = $self->through_login($ua)->request_mylist_list($group);
            unless( $res->is_content_success ){
                if( $res->is_error_noauth ){
                    croak "Cannot login because specified account is something wrong";
                }
                croak "Invalid content as 'mylistgroup'";
            }
        }
    }

    # it returns Net::NicoVideo::Content::NicoAPI::MylistItem
    return $res->parsed_content;
}

# NicoAPI.Mylist #add
sub add_mylist {
    my ($self, $group, $item, $token) = @_;
    my $ua = $self->get_user_agent;
    $token = $self->fetch_mylist_page->token
        unless( $token );
    my $res = $ua->request_mylist_add($group, $item, $token);
    croak "Request 'request_mylist_add' is error: @{[ $res->status_line ]}"
        if( $res->is_error );
    return $res->parsed_content;
}

# NicoAPI.Mylist #update
sub update_mylist {
    my ($self, $group, $item, $token) = @_;
    my $ua = $self->get_user_agent;
    $token = $self->fetch_mylist_page->token
        unless( $token );
    my $res = $ua->request_mylist_update($group, $item, $token);
    croak "Request 'request_mylist_update' is error: @{[ $res->status_line ]}"
        if( $res->is_error );
    return $res->parsed_content;
}

# NicoAPI.Mylist #remove
sub remove_mylist {
    my ($self, $group, $item, $token) = @_;
    my $ua  = $self->get_user_agent;
    $token = $self->fetch_mylist_page->token
        unless( $token );
    my $res = $ua->request_mylist_remove($group, $item, $token);
    croak "Request 'request_mylist_remove' is error: @{[ $res->status_line ]}"
        if( $res->is_error );
    return $res->parsed_content;
}

*delete_mylist = *remove_mylist;

# NicoAPI.Mylist #move
sub move_mylist {
    my ($self, $group, $target, $item, $token) = @_;
    my $ua  = $self->get_user_agent;
    $token = $self->fetch_mylist_page->token
        unless( $token );
    my $res = $ua->request_mylist_move($group, $target, $item, $token);
    croak "Request 'request_mylist_move' is error: @{[ $res->status_line ]}"
        if( $res->is_error );
    return $res->parsed_content;
}

# NicoAPI.Mylist #copy
sub copy_mylist {
    my ($self, $group, $target, $item, $token) = @_;
    my $ua  = $self->get_user_agent;
    $token = $self->fetch_mylist_page->token
        unless( $token );
    my $res = $ua->request_mylist_copy($group, $target, $item, $token);
    croak "Request 'request_mylist_copy' is error: @{[ $res->status_line ]}"
        if( $res->is_error );
    return $res->parsed_content;
}

1;
__END__

=pod

=head1 NAME

Net::NicoVideo - Perl Interface for accessing Nico Nico Douga

=head1 VERSION

This is an alpha version.
The API is still subject to change. Many features have not been implemented yet.

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
    
        $nnv->fetch_watch( $video_id );
        $nnv->fetch_video( $flv, $save_path );
        
        if( -s $save_path == $info->size_high ){
            print "ok\n";
        }else{
            print "finished, but it may have broken.\n";
        }
    }

=head1 DESCRIPTION

Nico Nico Douga (ニコニコ動画, lit. "Smile Videos") is a popular video sharing website
in Japan managed by Niwango, a subsidiary of Dwango.

A Distribution Net-NicoVideo is Perl Interface for accessing Nico Nico Douga.
This provides the consistent access method,
and contents are encapsulated and give facilities to clients.

And this class Net::NicoVideo is an utility which summarized the procedure 
for obtaining each object compactly.

An instance of this class uses Net::NicoVideo::UserAgent in the inside.
In other words, the client can use L<Net::NicoVideo::UserAgent> for work of a low level. 

=head1 CONSTRUCTOR

A constructor receives the hash reference which defines the field. 

    my $nnv = Net::NicoVideo->new({
        user_agent  => LWP::UserAgent->new,
        email       => 'your-nicovideo@email.address',
        password    => 'and-password',
        delay       => 1,
        });

There are access methods of a same name in each field. 

=head1 ACCESS METHOD (LOWER LEVEL)

The access method of the low level to the field. 

These are for setting and getting directly the field which passes 
neither allocating default nor validation.
When a value is given to an argument, the value is set as the field.

=head2 user_agent

Get or set an user agent that $nnv would access to Nico Nico Video via HTTP(s).

The user agent who sets up needs to be an instance of LWP::UserAgent.

    $nnv->user_agent(LWP::UserAgent->new);
    $ua = $nnv->user_agent;

=head2 email

Get or set email string for login to Nico Nico Video service.

    $nnv->email($email);
    $email = $nnv->email;

=head2 password

Get or set password string for login to Nico Nico Video service.

    $nnv->password($password);
    $password = $nnv->password;

=head2 delay

Get or set delay that is waiting seconds for every continuous access to a site.

    $nnv->delay($seconds);
    $seconds = $nnv->delay;

=head1 ACCESS METHOD (UPPER LEVEL)

The access method of a high level to the field.

Validation and a default value are prepared compared with the low level.

Access to the field after setting up the field by a constructor usually uses these. 

=head2 get_user_agent

It creates and returns the instance of L<Net::NicoVideo::UserAgent>.

=head2 get_email

Get email that the instance has.
If it is not defined, $ENV{NET_NICOVIDEO_EMAIL} is returned instead.

=head2 get_password

Get password that the instance has.
If it is not defined, $ENV{NET_NICOVIDEO_PASSWORD} is returned instead.

=head2 get_delay

Get delay that the instance has.
If it is not defined, $ENV{NET_NICOVIDEO_DELAY} is returned instead.
Both are not defined, returns 1.

=head1 FETCH METHOD

The method group which will get contents object. 

The methods of this category returns the instance of L<Net::NicoVideo::Content>.
They correspond to each contents of the site.

Please see sub classes under L<Net::NicoVideo::Content> for detail.

=head2 fetch_thumbinfo(video_id)

Get an instance of Net::NicoVideo::Content::ThumbInfo for video_id.

=head2 fetch_flv(video_id)

Get an instance of Net::NicoVideo::Content::Flv for video_id.

=head2 fetch_watch(video_id)

Get an instance of Net::NicoVideo::Content::Watch for video_id.

This means that the agent watches the video,
and this behavior is required before fetch_video.

=head2 fetch_video(video_id | flv | url, @args)

Get an instance of Net::NicoVideo::Content::Video for video_id, flv or url.
The url is value getting via $flv->url, and $flv is a Net::NicoVideo::Content::Flv
which is created by $nnv->fetch_flv.

The second parameter, it works like as request() method of LWP::UserAgent,
in fact, it is called.

An example, if it is a scalar value then it means that the file path to store contents.

=head2 fetch_thread(video_id | flv, \%options)

Get an instance of Net::NicoVideo::Content::Thread for video_id.

The hash reference of the second argument is an option
and receives the following key and the pair of a value. 

=over 4

=item "chats" => number

How many comments fetching from the newest thing. 
Default is 250. 

=item "fork" => boolean

If it is set the true, then the comment to fetch is limited only video owner's. #'
Default is false.

=back

=head1 Tag

The methods for tag search.

=head2 fetch_tag_rss(keyword, \%params)

The tag specified by keyword performs video search, and it returns results in RSS format.

The hash reference \%params can be given as options.
The key and value are as follows. 

=over 4

=item "sort" => 'f|v|r|m|l'

The keyword which sorts search results.

    f ... Contribute date
    v ... Reproduction number
    r ... The number of comments 
    m ... The number of mylists
    l ... Reproduction time

Default is "r".

=item "order" => a

Sort order, 'a' is ascend.

Default is undef which means descend.

=item "page" => number

When there are many search results, the result has separated to some pages. 
In this value, it specifies the page of what position to get. 

Default is 1.

Moreover, 1 page is 32 items at the maximum.

=back

=head2 fetch_tag_rss_by_recent_post(keyword, page)

It is the shortcut which fixes params and calls fetch_tag_rss 
so that it may get in descending order of contribution time.

=head1 Mylist RSS

The method group which will get "mylist" as RSS format.

=head2 fetch_mylist_rss(mylist | mylist_id)

Get an instance of L<Net::NicoVideo::Content::MylistRSS> for mylist.

=head1 NicoAPI BASE

The method group for get the base for accessing to NicoAPI.

NicoAPI is the name space of the library implemented by JavaScript,
in order to get "mylist" by an AJAX means,
and it has methods such as get of the data about "mylist", updating, and deletion.

And an access token is needed for execution of those other than an get method. 

=head2 fetch_mylist_page

Get an instance of L<Net::NicoVideo::Content::MylistPage> for take a "NicoAPI.token".

=head2 fetch_mylist_item(video_id)

Get an instance of L<Net::NicoVideo::Content::MylistItem>.
This method is useful for take a "NicoAPI.token" to update Mylist, "item_type" and "item_id" for video_id.

=head1 NicoAPI.MylistGroup

The method group of "NicoAPI.MylistGroup" which operates "mylist group".

Even if it omits a token, it is taken automatically and used.

=head2 list_mylistgroup()

Get an instance of L<Net::NicoVideo::Content::MylistGroup>.

This is equivalent to NicoAPI.MylistGroup#list.

=head2 get_mylistgroup(group_id)

Get an instance of L<Net::NicoVideo::Content::MylistGroup> for specified group_id.

This is equivalent to NicoAPI.MylistGroup#get.

=head2 add_mylistgroup(mylist, token)

Add a "mylist" to "mylist group".

This is equivalent to NicoAPI.MylistGroup#add

=head2 update_mylistgroup(mylist, token)

Update a "mylist".

This is equivalent to NicoAPI.MylistGroup#update

=head2 remove_mylistgroup(mylist, token)

Remove a "mylist".

This is equivalent to NicoAPI.MylistGroup#remove

=head2 delete_mylistgroup(mylist, token)

An alias of remove_mylistgroup().

=head1 NicoAPI.Mylist

The method group of "NicoAPI.Mylist" which operates "mylist".

Even if it omits a token, it is taken automatically and used.

=head2 list_mylist(group)

Get list of "mylist" item for group.

This is equivalent to NicoAPI.Mylist#list

=head2 add_mylist(group, item, [token])

Add item to group.

This is equivalent to NicoAPI.Mylist#add.

=head2 update_mylist(group, item, [token])

Update item of group.

This is equivalent to NicoAPI.Mylist#update.

=head2 remove_mylist(group, item, [token])

Remove item from group.

This is equivalent to NicoAPI.Mylist#remove.

=head2 delete_mylist(group, item, [token])

alias of remove_mylist().

=head2 move_mylist(group, target, item, [token])

Move item from group to target.

This is equivalent to NicoAPI.Mylist#move.

=head2 copy_mylist(group, target, item, [token])

Copy item from group to target.

This is equivalent to NicoAPI.Mylist#copy.

=head1 UTILITY METHOD

Other utility methods.

=head2 through_login(ua)

The user agent who gave the argument is led to a login page, and it logs in.
And the original user agent who gave the result is returned. 

The returning $ua is the same instance as what was given.

Typically, it is used as follows. 

    $res = $ua->request_mylist_rss($mylist);
    unless( $res->is_authflagged ){              # if not logged-in
        $ua = $self->through_login($ua);         # login
        $res = $ua->request_mylist_rss($mylist); # try again
    }

When login goes wrong, then croak.

=head2 download(video_id, file)

download() is a shortcut to download video which is identified by video_id.

For busy person, you can download a video by one liner like this:

    $ perl -MNet::NicoVideo -e 'Net::NicoVideo->new->download(@ARGV)' \
        smNNNNNN ./smile.mp4

Note that it is necessary to set environment variables in advance.

Although the media file to download may be MP4, it may not be so. 
Either MP4, or FLV or SWF is known now. 

By "thumbinfo" object which has same video_id can judge type of media.

=head1 ENVIRONMENT VARIABLE

    NET_NICOVIDEO_EMAIL
    NET_NICOVIDEO_PASSWORD
    NET_NICOVIDEO_DELAY

These obvious environment variables are effective. 
If the object has each value as its fields, priority is given to them.

=head1 SEE ALSO

L<LWP::UserAgent>
L<Net::NicoVideo::Content>
L<Net::NicoVideo::UserAgent>

=head1 REPOSITORY

Net::NicoVideo is hosted on github https://github.com/hiroaki/Net-NicoVideo

=head1 AUTHOR

WATANABE Hiroaki E<lt>hwat@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
