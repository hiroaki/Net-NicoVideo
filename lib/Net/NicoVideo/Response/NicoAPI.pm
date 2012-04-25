package Net::NicoVideo::Response::NicoAPI;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_18';

use base qw(Net::NicoVideo::Response);

use Net::NicoVideo::Content::NicoAPI;
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
        my $nico = Net::NicoVideo::Content::NicoAPI->new({
            status => $json->{status},
            });

        # member "error" exists when error occurs in all case
        $nico->error( Net::NicoVideo::Content::NicoAPI::Error->new($json->{error}) )
            if( $json->{error} );

        # member "id" in a case /mylist/add
        $nico->id( $json->{id} )
            if( exists $json->{id} );

        # member "mylistgroup" in case /mylistgroup/list or /mylistgroup/get
        my @mg = ();
        if( exists $json->{mylistgroup} ){
            if( ref( $json->{mylistgroup} ) ne 'ARRAY' ){
                $json->{mylistgroup} = [$json->{mylistgroup}];
            }
            for my $mg ( @{$json->{mylistgroup}} ){
                push @mg, Net::NicoVideo::Content::NicoAPI::MylistGroup->new($mg);
            }
            $nico->mylistgroup(\@mg);
        }

        # TODO member "mylistitem"
        my @mi = ();
        if( exists $json->{mylistitem} ){
            if( ref( $json->{mylistitem} ) ne 'ARRAY' ){
                $json->{mylistitem} = [$json->{mylistitem}];
            }
            for my $mi ( @{$json->{mylistitem}} ){
                my $item = Net::NicoVideo::Content::NicoAPI::MylistItem->new($mi);
                $item->item_data( Net::NicoVideo::Content::NicoAPI::MylistItem::ItemData->new($mi->{item_data}) );
                push @mi, $item;
            }
            $nico->mylistitem(\@mi);
        }


        $self->{_content_object} = $nico;
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
