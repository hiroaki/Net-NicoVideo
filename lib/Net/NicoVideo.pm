package Net::NicoVideo;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_23';

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

=encoding utf-8

=head1 NAME

Net::NicoVideo - Perl Interface for accessing Nico Nico Douga

=head1 VERSION

このモジュールは未完成です。
API は今後も変えられることが予想され、多くの機能がまだ未実装です。

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

ニコニコ動画は、日本で有名な動画共有サイトです。

Nico Nico Douga (ニコニコ動画, lit. "Smile Videos") is a popular video sharing website
in Japan managed by Niwango, a subsidiary of Dwango.

配布 Net-NicoVideo は、ニコニコ動画のサイト内外でやりとりされる
各オブジェクト（ HTTP メッセージ）へアクセスするためのインタフェースを提供します。
これにより、一貫したアクセス方法によってサイトへアクセスすることができ、
またカプセル化されたレスポンスを結果として得る事ができます。

A Distribution Net-NicoVideo is Perl Interface for accessing Nico Nico Douga.
This provides the consistent access method,
and contents are encapsulated and give facilities to clients.

そしてこのクラス Net::NicoVideo は、各オブジェクトを得る為の手続きを、
コンパクトに纏めたユーティリティとしてあります。
インスタンスは、その内部では Net::NicoVideo::UserAgent を利用しています。
言い換えれば、クライアントはより低レベルの仕事のために
Net::NicoVideo::UserAgent を使う事ができます。

その場合は、アクセスの段取りにクライアントは自ら注意を払う必要があることでしょう。
アクセス対象のサイトには、あるオブジェクトを得る為に、守るべきルールが存在するからです。

たとえば、動画ファイルを取得したい場合は、まずサイトにログインし、
flv と呼ばれるオブジェクトをリクエストし、更に動画を閲覧した上で、
動画の URL をリクエストしなければなりません。

クラス Net::NicoVideo のインスタンスはそうした暗黙のルールをメソッドとしてまとめ、
ユーザに便宜をはかります。

Net::NicoVideo, instance of this class, is an utility
that actually uses agent Net::NicoVideo::UserAgent.
In other words, you can also use Net::NicoVideo::UserAgent to tackle the low level problems.
However, in that case, you have to be cautious of sequence of accessing.

いずれにしても、このモジュールを使う際には、
サイトのオブジェクトについて（たとえば flv とは何か、 thumbinfo とは何かなど）、
ある程度の知識が要るかもしれません。
ただ、そういった事柄については Web を探す事ですぐに答を得る事が出来るでしょう。

なお、ニコニコ動画は 2012 年 5 月にサイトがリニューアルされました。
このモジュールが使える範囲は「ニコニコ動画（原宿）」と呼ばれる、リニューアル前のサイトです。
「ニコニコ動画（原宿）」は、いつまで使えるかは、このモジュールの作者は知りません。
──このモジュールは、いまもまだ使えているでしょうか？

=head1 CONSTRUCTOR

コンストラクタは、フィールドを定義するハッシュ・リファレンスを受け付けます。

    my $nnv = Net::NicoVideo->new({
        user_agent  => LWP::UserAgent->new,
        email       => 'your-nicovideo@email.address',
        password    => 'and-password',
        delay       => 1,
        });

各フィールドには同名のアクセス・メソッドがあります。
そちらの説明を参照して下さい。

=head1 ACCESS METHOD (LOWER LEVEL)

フィールドへの低レベルのアクセス・メソッド。

デフォルトやバリデーションを介さない、
フィールドを直接に設定・取得するためのものです。
引数に値を与えた場合はその値をフィールドに設定します。

=head2 user_agent

サイトへ HTTP （または HTTPS ）でアクセスするための
ユーザ・エージェントを取得、または設定します。
設定するユーザ・エージェントは LWP::UserAgent のインスタンスか、
そのサブクラスのインスタンスである必要があります。

Get or set user agent that $nnv would access to Nico Nico Video via HTTP(s).

    $nnv->user_agent(LWP::UserAgent->new);
    $ua = $nnv->user_agent;

=head2 email

サイトにログインする際に要求されるメールアドレス。

Get or set email string for login to Nico Nico Video service.

    $nnv->email($email);
    $email = $nnv->email;

=head2 password

サイトにログインする際に要求されるメールアドレスに対するパスワード。

Get or set password string for login to Nico Nico Video service.

    $nnv->password($password);
    $password = $nnv->password;

=head2 delay

サイトへ連続したアクセスをする際に、アクセスごとの間に差し挟む待ち時間（秒）。

Get or set delay seconds.

    $nnv->delay($seconds);
    $seconds = $nnv->delay;

=head1 ACCESS METHOD (UPPER LEVEL)

フィールドへの、高レベルのアクセス・メソッド。

低レベルのそれに対し、バリデーション、デフォルト値が用意されています。
コンストラクタでフィールドを設定した後のフィールドへのアクセスは、
通常は、これらを利用します。

=head2 get_user_agent

カスタマイズされたユーザ・エージェント Net::NicoVideo::UserAgent の
インスタンスを作成して返します。

Net::NicoVideo::UserAgent はフィールド user_agent に設定されたインスタンスを
装飾するデコレータになっています。
フィールド user_agent が設定されていない場合は、
デコレートされるコンポーネントとして LWP::UserAgent のインスタンスが生成されます。

Create an instance of Net::NicoVideo::UserAgent
that includes $nnv->user_agent has.
If it does not have then LWP::UserAgent would be created.

=head2 get_email

サイトにログインする際に要求されるメールアドレスを取得しますが、
フィールド email が未定義の場合は環境変数 NET_NICOVIDEO_EMAIL の値を返します。
それすらもなければ、単に undef が得られます。

Get email that the instance has.
If it is not defined, $ENV{NET_NICOVIDEO_EMAIL} is returned instead.

ノート：要求しようとするサイトのコンテンツによっては、ログインが必要ない場合もあります。
従って、 email および password は、未設定が許容されます。

=head2 get_password

サイトにログインする際に要求されるメールアドレスに対するパスワードを取得しますが、
フィールド password が未定義の場合は環境変数 NET_NICOVIDEO_PASSWORD の値を返します。
それすらもなければ、単に undef が得られます。

Get password that the instance has.
If it is not defined, $ENV{NET_NICOVIDEO_PASSWORD} is returned instead.

=head2 get_delay

Get delay that the instance has.
If it is not defined, $ENV{NET_NICOVIDEO_DELAY} is returned instead.
Both are not defined, returns 1.

=head1 FETCH METHOD

コンテンツ・オブジェクトを取得するメソッド群。

このカテゴリのメソッドは、サイトの各コンテンツに対応しており、
それぞれ、取得したコンテンツを解析した結果を持っている
Net::NicoVideo::Content のインスタンスを返します。

その、返されるオブジェクトの具体的な内容については、
コンテンツの種類ごとにサブクラスが定義されているため、
Net::NicoVideo::Content 以下の各サブクラスを参照して下さい。

Each methods return Net::NicoVideo::Content class 
which stored the result of having parsed the response.
Please see sub classes under Net::NicoVideo::Content for detail.

=head2 fetch_thumbinfo(video_id)

video_id に関する Thumbinfo オブジェクトを取得します。
なお Thumbinfo を得る為に、ログインは必要ありません。

Get an instance of Net::NicoVideo::Content::ThumbInfo for video_id.

=head2 fetch_flv(video_id)

video_id に関する Flv オブジェクトを取得します。

Get an instance of Net::NicoVideo::Content::Flv for video_id.

=head2 fetch_watch(video_id)

video_id に関する Watch オブジェクトを取得します。

Watch オブジェクトは仮想的なもので、実際は動画ページへアクセスし、
そこから得られる情報を持ったコンテンツ・オブジェクトです。

Get an instance of Net::NicoVideo::Content::Watch for video_id.

これは、サイトに対して、クライアントが動画を閲覧することを示します。
そしてその振る舞いは、 fetch_video を呼ぶ直前に必要なことになっています。

This means that the agent watches the video,
and this behavior is required before fetch_video.

=head2 fetch_video(video_id, @args)

=head2 fetch_video(flv, @args)

=head2 fetch_video(url, @args)

第一引数に与えた video_id 、 flv オブジェクト、または直接の URL の動画のデータを取得します。
URL の場合、それは flv オブジェクトから取得できる URL でなければ意味をなさないでしょう。

Get an instance of Net::NicoVideo::Content::Video for video_id, flv or url.
The url is value getting via $flv->url, and $flv is a Net::NicoVideo::Content::Flv
which is created by $nnv->fetch_flv.

取得したデータはそれ以降の引数によって処理される方法が異なります。
このメソッドは LWP::UserAgent の request メソッドと同じで、
実際、内部では透過的にそれを呼んでいます。
たとえば、第二引数にスカラー値を与えた場合は、それはファイル・パスとして解釈され、
動画コンテンツはそのファイルに保存されます。
詳しくは LWP::UserAgent の request メソッドを参照して下さい。

The second parameter, it works like as request() method of LWP::UserAgent,
in fact, it is called.
An example, if it is a scalar value then it means that the file path to store contents.

=head2 fetch_thread(video_id, \%options)

=head2 fetch_thread(flv, \%options)

第一引数に与えた video_id もしくは flv オブジェクトが示す動画の、コメントを取得します。

Get an instance of Net::NicoVideo::Content::Thread for video_id.

第二引数のハッシュ・リファレンスはオプションで、次のキーと値のペアを受け取ります。

=over 4

=item "chats" => number

最新のものから何件のコメントを取得するか。デフォルトは 250 です。

=item "fork" => boolean

取得するコメントを、動画オーナーのコメントだけに限定します。デフォルトは偽です。

=back

=head1 Tag

タグ検索のためのメソッド。

=head2 fetch_tag_rss(keyword, \%params)

keyword で指定したタグで動画検索を行い、結果を RSS 形式で返します。

オプションでハッシュリファレンス params を与える事ができます。
そのキーと値は次のとおりです。

=over 4

=item "sort" => 'f|v|r|m|l'

検索結果を並び替えるキーワードを指定します。

    f ... 投稿日時
    v ... 再生数
    r ... コメント数
    m ... マイリスト数
    l ... 再生時間

無指定のときは r コメント数になります。

=item "order" => a

並び替えの順序を指定します。 'a' を指定すると ASCEND つまり降順です。

無指定のときは DESCEND 昇順です。

=item "page" => number

検索結果が多い場合は、結果は幾つかのページに別れており、何番目のページを得るかを指定します。

無指定のときは 1 ページ目を得ます。

なお 1 ページは最大で 32 件です。

=back

=head2 fetch_tag_rss_by_recent_post(keyword, page)

投稿日時の降順で得るように params を固定して fetch_tag_rss を呼び出すショートカットです。

引数にはタグと、オプションでページ番号を指定します。

=head1 Mylist RSS

マイリストの RSS を取得するためのメソッド。

=head2 fetch_mylist_rss(mylist)

=head2 fetch_mylist_rss(mylist_id)

引数に指定した mylist または mylist_id のマイリストの
RSS を保持するコンテンツ・オブジェクトを返します。

Get an instance of Net::NicoVideo::Content::MylistRSS for mylist.

ノート：非公開のマイリストでも、サイトにログインしていることで、それを得る事ができます（？）

=head1 NicoAPI BASE

NicoAPI へアクセスするための下地を得るためのメソッド群。

NicoAPI はマイリスト類を AJAX 手段で得る為に JavaScript で実装されているライブラリの名前空間で、
マイリスト類のデータの取得、更新、削除などのメソッドを持っています。
そして、取得するためのメソッド以外の実行には、アクセス・トークンが必要になります。

=head2 fetch_mylist_page

ログインしているユーザの「マイリスト」ページを取得し、
そのページを解析した結果を持つ Net::NicoVideo::Content::MylistPage オブジェクトを返します。

Get an instance of Net::NicoVideo::Content::MylistPage for take a "NicoAPI.token".

主にアクセス・トークンを得るためのものです。

=head2 fetch_mylist_item(video_id)

ログインしているユーザで、 video_id に対する「マイリストの追加」ページを取得し、
そのページを解析した結果を持つ Net::NicoVideo::Content::MylistItem オブジェクトを返します。

Get an instance of Net::NicoVideo::Content::MylistItem,
This method is useful for take a "NicoAPI.token" to update Mylist, "item_type" and "item_id" for video_id.

これにより video_id の動画に対する "item_id" および "item_type" を得る事ができます。

なお "item_type" は、動画に対してはゼロ "0" が固定の値となっていますが、
このメソッドではそれをリクエストして得たページのコンテンツ内容から動的に取得します。
また、そのページではアクセス・トークンが得られるのでついでにそれも取得します。

=head1 NicoAPI.MylistGroup

NicoAPI.MylistGroup のメソッド群。

マイリスト・グループを操作するメソッド群です。
これらのメソッドで、何かを取得すること *以外* の実行には、
アクセス・トークンが必要になります。

ただしトークン省略しても、それは内部で自動的に取得され、用いられます。
しかしすでにアクセス・トークンを持っている場合は、それを指定する事で、
アクセス・トークンの取得の為のサイトへのアクセスをなくす事ができます。

=head2 list_mylistgroup()

ログインしたユーザのマイリスト・グループのリストを取得します。

Get an instance of Net::NicoVideo::Content::MylistGroup for user own

これは、 NicoAPI.MylistGroup#list に相当します。

This is equivalent to NicoAPI.MylistGroup#list.

=head2 get_mylistgroup(group_id)

指定した grpup_id のマイリスト・グループを取得します。

Get an instance of Net::NicoVideo::Content::MylistGroup for specified group_id.

これは、 NicoAPI.MylistGroup#get に相当します。

This is equivalent to NicoAPI.MylistGroup#get.

=head2 add_mylistgroup(mylist, token)

ログインしたユーザのマイリスト・グループにマイリストを追加します。

Add a mylist to mylistgroup.

これは、 NicoAPI.MylistGroup#add に相当します。

This is equivalent to NicoAPI.MylistGroup#add

=head2 update_mylistgroup(mylist, token)

ログインしたユーザのマイリスト・グループの情報を更新します。

Update a mylist.

これは、 NicoAPI.MylistGroup#update に相当します。

This is equivalent to NicoAPI.MylistGroup#update

=head2 remove_mylistgroup(mylist, token)

=head2 delete_mylistgroup(mylist, token)

指定したマイリストをログインしたユーザのマイリスト・グループから削除します。

Remove a mylist.

This is equivalent to NicoAPI.MylistGroup#remove

これは、 NicoAPI.MylistGroup#remove に相当します。

=head1 NicoAPI.Mylist

NicoAPI.Mylist のメソッド群。

マイリストのアイテムを操作するメソッド群です。
これらのメソッドで、何かを取得すること *以外* の実行には、
アクセス・トークンが必要になります。

ただしトークン省略しても、それは内部で自動的に取得され、用いられます。
しかしすでにアクセス・トークンを持っている場合は、それを指定する事で、
アクセス・トークンの取得の為のサイトへのアクセスをなくす事ができます。

=head2 list_mylist(group)

group_id のマイリストのアイテム一覧を得ます。
これは、 NicoAPI.Mylist#list に相当します。

=head2 add_mylist(group, item, [token])

アイテム item をマイリスト mylist に追加します。
これは、 NicoAPI.Mylist#add に相当します。

=head2 update_mylist(group, item, [token])

マイリスト mylist のアイテム item を更新します。
これは、 NicoAPI.Mylist#update に相当します。

=head2 remove_mylist(group, item, [token])

=head2 delete_mylist(group, item, [token])

マイリスト mylist のアイテム item を削除します。
これは、 NicoAPI.Mylist#remove に相当します。

=head2 move_mylist(group, target, item, [token])

マイリスト mylist のアイテム item をマイリスト target へ移動します。
これは、 NicoAPI.Mylist#move に相当します。

=head2 copy_mylist(group, target, item, [token])

マイリスト mylist のアイテム item をマイリスト target へコピーします。
これは、 NicoAPI.Mylist#copy に相当します。

=head1 UTILITY METHOD

その他ユーティリティ。

=head2 through_login(ua)

引数に与えたユーザ・エージェント Net::NicoVideo::UserAgent のインスタンスを、
ログイン・ページへ導き、そしてログインを行います。
そして、その結果を持たせた元のユーザ・エージェントを返却します。

引数に与えたインスタンスと、
返却されるインスタンスは同じインスタンスです。

The returning $ua is the same instance as what was given.

典型的には、次のように使われます。
ログインが必要なページを、まずログインすることなしにアクセスを試み、
そのレスポンスから、ログインが要求されている事を知ったとき、
はじめてそこでログインを試み、
そしてログインした状態でコンテンツを改めて取得します。

This returns $ua which made it go via a login page:

    $res = $ua->request_mylist_rss($mylist);
    unless( $res->is_authflagged ){              # if not logged-in
        $ua = $self->through_login($ua);         # login
        $res = $ua->request_mylist_rss($mylist); # try again
    }

ログインに失敗した際は croak されます。

=head2 download(video_id, file)

動画ファイルをダウンロードするための一連の段取りをまとめた、
ショートカットです。

A shortcut to download video which is identified by video_id.

忙しい時には、ワンライナーでお望みの動画をダウンロードできます。
次のように：

For busy person, you can download a video by one liner like this:

    $ perl -MNet::NicoVideo -e 'Net::NicoVideo->new->download(@ARGV)' \
        smNNNNNN ./smile.mp4

ただし、これから説明する環境変数を予めセットしておく必要があるでしょう。

Note that it is necessary to set environment variables in advance.

ノート：ダウンロードされるメディア・ファイルは、 MP4 かもしれませんが、
そうでないかもしれません。
現在知られているのは MP4, FLV または SWF のいずれかです。
前もって Thumbinfo を取得して、その内容から判断することもできます。

=head1 ENVIRONMENT VARIABLE

    NET_NICOVIDEO_EMAIL
    NET_NICOVIDEO_PASSWORD
    NET_NICOVIDEO_DELAY

これらの明らかなる名前の環境変数が、その名の示すとおりの役割で有効です。

These obvious environment variables are effective. 
If the object has each value as its members, priority is given to them.

=head1 SEE ALSO

L<LWP::UserAgent>
L<Net::NicoVideo::Content>
L<Net::NicoVideo::UserAgent>

=head1 REPOSITORY

Net::NicoVideo is hosted on github https://github.com/hiroaki/Net-NicoVideo

=head1 AUTHOR

WATANABE Hiroaki E<lt>hwat@mac.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
