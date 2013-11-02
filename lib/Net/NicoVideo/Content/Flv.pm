package Net::NicoVideo::Content::Flv;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.27_01';

use base qw(Net::NicoVideo::Content);
use Carp qw(croak);
use CGI::Simple;

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

sub members { # implement
    my @copy = @Members;
    @copy;
}

sub parse { # implement
    my $self = shift;
    $self->load($_[0]) if( defined $_[0] );

    my $cgi = CGI::Simple->new($self->_decoded_content);
    for my $name ( $cgi->param ){
        $self->$name( $cgi->param($name) )
            if( $self->can($name) );
    }
    return $self;
}

sub is_economy {
    my $self = shift;
    my $url = $self->url or croak "url is not set, does not it fetch flv data yet?";
    return $url =~ /low$/ ? 1 : 0;
}

1;
