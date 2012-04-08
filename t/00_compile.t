use strict;
use Test::More tests => 15;

BEGIN {
    use_ok 'Net::NicoVideo';
    use_ok 'Net::NicoVideo::Content::Flv';
    use_ok 'Net::NicoVideo::Content::Mylist';
    use_ok 'Net::NicoVideo::Content::ThumbInfo';
    use_ok 'Net::NicoVideo::Content::Video';
    use_ok 'Net::NicoVideo::Content::Watch';
    use_ok 'Net::NicoVideo::Decorator';
    use_ok 'Net::NicoVideo::Request';
    use_ok 'Net::NicoVideo::Response::Flv';
    use_ok 'Net::NicoVideo::Response::Mylist';
    use_ok 'Net::NicoVideo::Response::ThumbInfo';
    use_ok 'Net::NicoVideo::Response::Video';
    use_ok 'Net::NicoVideo::Response::Watch';
    use_ok 'Net::NicoVideo::Response';
    use_ok 'Net::NicoVideo::UserAgent';
}
