package Net::NicoVideo::Response;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_02';

use vars qw($AUTOLOAD);

sub AUTOLOAD {
    my $self = shift;
    my $component = $self->component;
    return if $AUTOLOAD =~ /::DESTROY$/;
    my $method = $AUTOLOAD;
    $method =~ s/.+:://;
    $component->$method(@_);
}

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $http_response = shift;
    my $self = {
        component => $http_response,
        };
    bless $self, $class;
    return $self;
}

sub component {
    my $self = shift;
    return @_ ? $self->{component} = shift : $self->{component};
}

sub parsed_content { # abstruct
    my $self = shift;
    $self->component->decoded_content;
}

sub is_content_success { # abstruct
    my $self = shift;
    $self->component->is_success;
}

sub is_content_error { # abstruct
    my $self = shift;
    $self->component->is_error;
}

1;
