package Net::NicoVideo::Content::MylistRSS;

use strict;
use warnings;
use utf8;
use vars qw($VERSION);
$VERSION = '0.01_13';

use base qw/Net::NicoVideo::Decorator/;

sub members {
    ();
}

sub is_closed {
    my $self = shift;
    if( $self->title eq 'マイリスト‐ニコニコ動画'
    and $self->link eq 'http://www.nicovideo.jp/'
    and $self->description eq 'このマイリストは非公開に設定されています。'
    ){
        return 1;
    }
    return 0;
}

1;
__END__
