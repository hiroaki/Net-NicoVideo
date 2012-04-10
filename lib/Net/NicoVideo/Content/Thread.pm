use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_11';


package Net::NicoVideo::Content::Chat;
use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
thread
no
vpos
date
mail
user_id
anonymity
value
);
__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}


package Net::NicoVideo::Content::ViewCounter;
use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
video
id
mylist
);
__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}

package Net::NicoVideo::Content::Thread;
use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
resultcode
thread
last_res
ticket
revision
fork
server_time

view_counter
chats
);
__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}

sub count {
    my $self = shift;
    scalar @{$self->chats};
}

sub get_comments {
    my $self = shift;
    wantarray ? @{$self->chats} : $self->chats;
}

1;
__END__
