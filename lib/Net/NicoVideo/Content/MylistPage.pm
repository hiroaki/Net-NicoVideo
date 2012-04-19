package Net::NicoVideo::Content::MylistPage;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_17';

use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
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

Net::NicoVideo::Content::MylistPage - Content of the page

=head1 SYNOPSIS

    Net::NicoVideo::Content::MylistPage->new({
        token => "...",
        });

=head1 DESCRIPTION

Parsed content of the page L<http://www.nicovideo.jp/my/mylist>.
This place is for owner which login Nico Nico Douga.

An important thing that this page is having "NicoAPI.token" to update Mylist.

=head1 SEE ALSO

L<Net::NicoVideo::Response::MylistPage>

=cut
