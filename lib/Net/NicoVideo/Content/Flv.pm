package Net::NicoVideo::Content::Flv;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_08';

use base qw(Class::Accessor::Fast);
use Carp qw(croak);

use vars qw(@Members);
@Members = qw(
thread_id
l
url
link
ms
user_id
is_premium
nickname
time
done
feedrev
ng_rv
hms
hmsp
hmst
hmstk
rpu
);

__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}

sub is_economy {
    my $self = shift;
    my $url = $self->url or croak "url is not set, does not it fetch flv data yet?";
    return $url =~ /low$/ ? 1 : 0;
}

1;
