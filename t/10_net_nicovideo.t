use strict;
use Test::More;

use Net::NicoVideo;
use LWP::UserAgent;


isa_ok( Net::NicoVideo->new, 'Net::NicoVideo');

ok( defined $Net::NicoVideo::VERSION, 'defined VERSION');
is( $Net::NicoVideo::DELAY_DEFAULT, 1, 'default delay');


#-----------------------------------------------------------
# accessor
#

do {
    my ($nnv, $ua, $email, $password, $delay);

    $nnv = Net::NicoVideo->new;

    # member accessor
    is $nnv->user_agent, undef, 'default user_agent';
    is $nnv->email, undef, 'default email';
    is $nnv->password, undef, 'default password';
    is $nnv->delay, undef, 'default delay';

    # setter/getter
    $ua = new LWP::UserAgent;
    is $nnv->user_agent($ua), $ua, 'set user_agent';
    is $nnv->user_agent,      $ua, 'get user_agent';

    $email = 'mail@address.hoge';
    is $nnv->email($email), $email, 'set email';
    is $nnv->email,         $email, 'get email';

    $password = 'foobar';
    is $nnv->password($password), $password, 'set password';
    is $nnv->password,            $password, 'get password';

    $delay = 100;
    is $nnv->delay($delay), $delay, 'set delay';
    is $nnv->delay,         $delay, 'get delay';
};


#-----------------------------------------------------------
# getter
#

do {
    my ($nnv, $ua, $email, $password, $delay);

    $nnv = Net::NicoVideo->new;
    
    isa_ok $nnv->get_user_agent, "Net::NicoVideo::UserAgent", "default user_agent";
    isa_ok $nnv->user_agent, "LWP::UserAgent", "ua set after get";

    do {
        local %ENV = ();
        is $nnv->get_email, undef, 'default undef get_email';
        is $nnv->get_password, undef, 'default undef get_password';
    };
    do {
        local $ENV{NET_NICOVIDEO_EMAIL} = 'net@nicovideo.email';
        local $ENV{NET_NICOVIDEO_PASSWORD} = 'hahahaha';
        is $nnv->get_email, 'net@nicovideo.email', 'get_email via env';
        is $nnv->get_password, 'hahahaha', 'get_password via env';
    };
};

#-----------------------------------------------------------
# utils
#

# through_login
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('through_login'), 'can through_login');
};

# download
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('download'), 'can download');
};


#-----------------------------------------------------------
# fetch
# 

# fetch_thumbinfo
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('fetch_thumbinfo'), 'can fetch_thumbinfo');
};

# fetch_flv
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('fetch_flv'), 'can fetch_flv');
};

# fetch_watch
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('fetch_watch'), 'can fetch_watch');
};

# fetch_video
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('fetch_video'), 'can fetch_video');
};

# fetch_thread
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('fetch_thread'), 'can fetch_thread');
};


#-----------------------------------------------------------
# Mylist RSS
# 

# fetch_mylistrss
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('fetch_mylistrss'), 'can fetch_mylistrss');
};


#-----------------------------------------------------------
# Mylist Base
# 

# fetch_mylistpage
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('fetch_mylistpage'), 'can fetch_mylistpage');
};

# fetch_mylistitem
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('fetch_mylistitem'), 'can fetch_mylistitem');
};


#-----------------------------------------------------------
# NicoAPI.MylistGroup
# 

# fetch_mylistgroup
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('fetch_mylistgroup'), 'can fetch_mylistgroup');
};

# add_mylistgroup
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('add_mylistgroup'), 'can add_mylistgroup');
};

# update_mylistgroup
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('update_mylistgroup'), 'can update_mylistgroup');
};

# remove_mylistgroup
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('remove_mylistgroup'), 'can remove_mylistgroup');
};


#-----------------------------------------------------------
# NicoAPI.Mylist
# 

# fetch_mylist
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('fetch_mylist'), 'can fetch_mylist');
};

# add_mylist
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('add_mylist'), 'can add_mylist');
};

# update_mylist
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('update_mylist'), 'can update_mylist');
};

# remove_mylist
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('remove_mylist'), 'can remove_mylist');
};

# move_mylist
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('move_mylist'), 'can move_mylist');
};

# copy_mylist
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('copy_mylist'), 'can copy_mylist');
};


done_testing();
__END__
