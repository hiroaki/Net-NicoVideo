use strict;
use warnings;
use Test::More tests => 24;

BEGIN {
    use_ok 'Net::NicoVideo';
    use_ok 'Net::NicoVideo::Content::Flv';
    use_ok 'Net::NicoVideo::Content::MylistItem';
    use_ok 'Net::NicoVideo::Content::MylistPage';
    use_ok 'Net::NicoVideo::Content::MylistRSS';
    use_ok 'Net::NicoVideo::Content::NicoAPI';
    use_ok 'Net::NicoVideo::Content::Thread';
    use_ok 'Net::NicoVideo::Content::ThumbInfo';
    use_ok 'Net::NicoVideo::Content::Video';
    use_ok 'Net::NicoVideo::Content::Watch';
    use_ok 'Net::NicoVideo::Decorator';
    use_ok 'Net::NicoVideo::Request';
    use_ok 'Net::NicoVideo::Response::Flv';
    use_ok 'Net::NicoVideo::Response::MylistItem';
    use_ok 'Net::NicoVideo::Response::MylistPage';
    use_ok 'Net::NicoVideo::Response::MylistRSS';
    use_ok 'Net::NicoVideo::Response::NicoAPI';
    use_ok 'Net::NicoVideo::Response::Thread';
    use_ok 'Net::NicoVideo::Response::ThumbInfo';
    use_ok 'Net::NicoVideo::Response::Video';
    use_ok 'Net::NicoVideo::Response::Watch';
    use_ok 'Net::NicoVideo::Response';
    use_ok 'Net::NicoVideo::UserAgent';
    use_ok 'Net::NicoVideo::URL';
}

1;
__END__
