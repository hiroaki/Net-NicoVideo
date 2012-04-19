package Net::NicoVideo::Response::MylistGroup;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_17';

use base qw/Net::NicoVideo::Response/;

use Net::NicoVideo::Content::Mylist;
use Net::NicoVideo::Content::MylistGroup;
use JSON 2.01;

sub parse {
    my $self = shift;
    $self->{_parsed_content} ||= decode_json( $self->_component->decoded_content );
}

sub parsed_content { # implement
    my $self = shift;
    unless( $self->{_content_object} ){
        my $json = $self->parse;
        
        # member "status" exists in all case
        my $mg = Net::NicoVideo::Content::MylistGroup->new({
            status => $json->{status},
            });

        # member "error" exists when error occurs in all case
        $mg->error( Net::NicoVideo::Content::MylistError->new($json->{error}) )
            if( $json->{error} );

        # member "id" in a case /mylist/add
        $mg->id( $json->{id} )
            if( exists $json->{id} );

        # member "mylistgroup" in case /mylistgroup/list or /mylistgroup/get
        my @mylists = ();
        if( ref( $json->{mylistgroup} ) ne 'ARRAY' ){
            $json->{mylistgroup} = [$json->{mylistgroup}];
        }
        for my $ml ( @{$json->{mylistgroup}} ){
            push @mylists, Net::NicoVideo::Content::Mylist->new($ml);
        }


        $mg->mylistgroup(\@mylists);

        $self->{_content_object} = $mg;
    }
    $self->{_content_object};
}

sub is_content_success { # implement
    my $self = shift;
    my $json = $self->parse;
    if( $json->{status} and $json->{status} eq 'ok' ){
        return 1;
    }else{
        return 0;
    }
}

sub is_content_error { # implement
    not shift->is_content_success;
}

sub is_error_noauth { # shortcut
    my $self = shift;
    $self->parsed_content->is_error_noauth;
}

1;
__END__
