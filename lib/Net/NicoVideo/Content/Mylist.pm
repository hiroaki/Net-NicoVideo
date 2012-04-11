use strict;
use warnings;

package Net::NicoVideo::Content::Mylist;

use vars qw($VERSION);
$VERSION = '0.01_13';

use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
id
user_id
name
description
public
default_sort
create_time
update_time
sort_order
icon_id
);

__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}

package Net::NicoVideo::Content::MylistError;

use vars qw($VERSION);
$VERSION = '0.01_13';

use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
code
description
);

__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}

1;
__END__
