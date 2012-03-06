use strict;
use Test::More tests => 15;

BEGIN {
    use_ok 'Net::NicoVideo';
    use_ok 'Net::NicoVideo::Decorator';
    use_ok 'Net::NicoVideo::Flv';
    use_ok 'Net::NicoVideo::MyList';
    use_ok 'Net::NicoVideo::Request';
    use_ok 'Net::NicoVideo::Response::Flv';
    use_ok 'Net::NicoVideo::Response::MyList';
    use_ok 'Net::NicoVideo::Response::ThumbInfo';
    use_ok 'Net::NicoVideo::Response::Video';
    use_ok 'Net::NicoVideo::Response::Watch';
    use_ok 'Net::NicoVideo::Response';
    use_ok 'Net::NicoVideo::ThumbInfo';
    use_ok 'Net::NicoVideo::UserAgent';
    use_ok 'Net::NicoVideo::Video';
    use_ok 'Net::NicoVideo::Watch';
}
