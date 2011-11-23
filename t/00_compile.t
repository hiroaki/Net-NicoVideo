use strict;
use Test::More tests => 7;

BEGIN {
    use_ok 'Net::NicoVideo';
    use_ok 'Net::NicoVideo::Flv';
    use_ok 'Net::NicoVideo::Request';
    use_ok 'Net::NicoVideo::Response::Flv';
    use_ok 'Net::NicoVideo::Response::ThumbInfo';
    use_ok 'Net::NicoVideo::Response';
    use_ok 'Net::NicoVideo::ThumbInfo';
}
