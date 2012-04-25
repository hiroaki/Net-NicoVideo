package Net::NicoVideo::Response::MylistItem;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_18';

use base qw/Net::NicoVideo::Response/;
use Net::NicoVideo::Content::MylistItem;
use HTML::Parser 3.00;

sub parse {
    my $self = shift;
    $self->{_parsed_content} ||= $self->_component->decoded_content;
}

sub parsed_content { # implement
    my $self = shift;
    unless( $self->{_content_object} ){

        my $params = {};
        my $content = $self->parse;

        # take NicoAPI.token
        if( $content =~ /NicoAPI\.token\s*=\s*"([-\w]+)"/ ){
            $params->{token} = $1;
        }

        # take item_type and item_id using HTML::Parser
        my $item_type   = undef;
        my $item_id     = undef;
        my $description = undef;
        my $p;
        $p = HTML::Parser->new(
            api_version => 3,
            start_h => [ sub {
                    my ($tagname, $attr) = @_;
                    if( lc($tagname) eq 'input' ){
                        if( exists $attr->{name} and lc($attr->{name}) eq 'item_type' ){
                            $item_type  = $attr->{value};
                        }
                        if( exists $attr->{name} and lc($attr->{name}) eq 'item_id' ){
                            $item_id    = $attr->{value};
                        }
                        if( exists $attr->{name} and lc($attr->{name}) eq 'description' ){
                            $description= $attr->{value};
                        }
                    }
                    $p->eof if( defined $item_type and defined $item_id and defined $description );
                }, 'tagname, attr']);
        $p->parse($content);
        $params->{item_type}   = $item_type;
        $params->{item_id}     = $item_id;
        $params->{description} = $description;

        $self->{_content_object} = Net::NicoVideo::Content::MylistItem->new($params);
    }
    $self->{_content_object};
}

sub is_content_success { # implement
    my $self = shift;
    my $content = $self->parsed_content;
    if( defined $content->item_id and defined $content->item_type ){
        return 1;
    }else{
        return 0;
    }
}

sub is_content_error { # implement
    not shift->is_content_success;
}

1;
__END__
