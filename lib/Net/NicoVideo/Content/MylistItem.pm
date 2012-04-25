package Net::NicoVideo::Content::MylistItem;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_18';

use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
item_type
item_id
description
token
);

__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}

1;
__END__

=pod

=head1 NAME

Net::NicoVideo::Content::MylistItem - item_type and item_id by video_id

=head1 SYNOPSIS

    Net::NicoVideo::Content::MylistItem->new({
        item_type   => 0,
        item_id     => 'sm00000000',
        description => 'mylist comment',
        token       => '12345678-1234567890-abcdef0123456789abcdef0123456789abcdef01',
        });

=head1 DESCRIPTION

Parsed content of the page L<http://www.nicovideo.jp/mylist_add/video/${video_id}>.

An important thing that this page is having "item_type" and "item_id" for specific $video_id,
and "token" to update Mylist.

=head1 SEE ALSO

L<Net::NicoVideo::Response::MylistItem>

=cut
