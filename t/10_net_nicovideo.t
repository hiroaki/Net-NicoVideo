use strict;
use Test::More qw/no_plan/;

use Net::NicoVideo;
use LWP::UserAgent;

# accessor
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


# getter
do {
    my ($nnv, $ua, $email, $password, $delay);

    $nnv = Net::NicoVideo->new;

    isa_ok $nnv->get_user_agent, "Net::NicoVideo::UserAgent";
    isa_ok $nnv->user_agent, "LWP::UserAgent";

    do {
        local %ENV = ();
        is $nnv->get_email, undef, 'default get_email';
        is $nnv->get_password, undef, 'default get_password';
    };
    do {
        local $ENV{NET_NICOVIDEO_EMAIL} = 'net@nicovideo.email';
        local $ENV{NET_NICOVIDEO_PASSWORD} = 'hahahaha';
        is $nnv->get_email, 'net@nicovideo.email', 'email by env';
        is $nnv->get_password, 'hahahaha', 'password by env';
    };
};

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

# fetch_mylist
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('fetch_mylistrss'), 'can fetch_mylistrss');
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

# download
TODO: {
    local $TODO = "writing test";
    my $nnv = Net::NicoVideo->new;
    ok( $nnv->can('download'), 'can download');
};


#done_testing();
__END__
