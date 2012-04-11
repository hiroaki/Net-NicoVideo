package Net::NicoVideo::Content::MylistGroup;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_12';

use base qw(Class::Accessor::Fast);
use vars qw(@Members);
@Members = qw(
mylistgroup
error
status
);

__PACKAGE__->mk_accessors(@Members);

sub members {
    my @copy = @Members;
    @copy;
}

sub is_status_ok {
    my $self = shift;
    $self->status and $self->status eq 'ok';
}

sub error_code {
    my $self = shift;
    $self->error->{code};
}

sub error_description {
    my $self = shift;
    $self->error->{description};
}

sub is_error_noauth {
    my $self = shift;
    $self->error and $self->error->{code} and $self->error->{code} eq 'NOAUTH';
}

1;
__END__
