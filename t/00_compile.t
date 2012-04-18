use strict;
use warnings;
use Test::More tests => 20;

BEGIN {
    use_ok 'Net::NicoVideo';
    use_ok 'Net::NicoVideo::Content::Flv';
    use_ok 'Net::NicoVideo::Content::Mylist';
    use_ok 'Net::NicoVideo::Content::MylistRSS';
    use_ok 'Net::NicoVideo::Content::MylistGroup';
    use_ok 'Net::NicoVideo::Content::Thread';
    use_ok 'Net::NicoVideo::Content::ThumbInfo';
    use_ok 'Net::NicoVideo::Content::Video';
    use_ok 'Net::NicoVideo::Content::Watch';
    use_ok 'Net::NicoVideo::Decorator';
    use_ok 'Net::NicoVideo::Request';
    use_ok 'Net::NicoVideo::Response::Flv';
    use_ok 'Net::NicoVideo::Response::MylistRSS';
    use_ok 'Net::NicoVideo::Response::MylistGroup';
    use_ok 'Net::NicoVideo::Response::Thread';
    use_ok 'Net::NicoVideo::Response::ThumbInfo';
    use_ok 'Net::NicoVideo::Response::Video';
    use_ok 'Net::NicoVideo::Response::Watch';
    use_ok 'Net::NicoVideo::Response';
    use_ok 'Net::NicoVideo::UserAgent';
}

1;
__END__
