package Net::NicoVideo::Decorator;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_03';

use vars qw($AUTOLOAD);

sub AUTOLOAD {
    my $self = shift;
    return if $AUTOLOAD =~ /::DESTROY$/;
    my $method = $AUTOLOAD;
    $method =~ s/.+:://;
    $self->_component->$method(@_);
}

sub new {
    my $class = shift;
       $class = ref $class || $class;
    my $self  = {
        _component => $_[0],
        };
    bless $self, $class;
}

sub _component {
    my $self = shift;
    return @_ ? $self->{_component} = shift : $self->{_component};
}

1;
__END__


=pod

=head1 NAME

Net::NicoVideo::Decorator - Interface decorator pattern

=head1 SYNOPSIS

    package Foo::Bar;
    use base qw(Net::NicoVideo::Decorator);

    sub new {
        my ($class, $component, @extra_args) = @_;
        my $self = $class->SUPER::new($component);
        ...
        $self->initialize(@extra_args);
        ...
        ...
    }
    

    package main;
    Foo::Bar->new(Some::Class->new);

=head1 DESCRIPTION

This provides common interface for the decorator pattern easily.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

WATANABE Hiroaki E<lt>hwat@mac.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
