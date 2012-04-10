package Net::NicoVideo::Response::Thread;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01_11';

use base qw/Net::NicoVideo::Response/;

use XML::TreePP;
use Net::NicoVideo::Content::Thread;

sub parse {
    my $self = shift;
    unless( $self->{_parsed_content} ){
        $self->{_parsed_content} = XML::TreePP->new( force_array => 'chat' )
                                    ->parse($self->_component->decoded_content);
    }
    return $self->{_parsed_content};
}

sub parsed_content { # implement
    my $self = shift;
    unless( $self->{_content_object} ){
        my $tree = $self->parse;

        my @chats = ();
        for my $c ( @{$tree->{packet}->{chat}} ){
            push @chats, Net::NicoVideo::Content::Chat->new({
                thread      => $c->{-thread},
                no          => $c->{-no},
                vpos        => $c->{-vpos},
                date        => $c->{-date},
                mail        => $c->{-mail},
                user_id     => $c->{-user_id},
                anonymity   => $c->{-anonymity},
                value       => $c->{'#text'},
                });
        }

        my $v = $tree->{packet}->{view_counter};
        my $vc = Net::NicoVideo::Content::ViewCounter->new({
            video       => $v->{-video},
            id          => $v->{-id},
            mylist      => $v->{-mylist},
            });
        
        my $t = $tree->{packet}->{thread};
        my $thread = Net::NicoVideo::Content::Thread->new({
            resultcode  => $t->{-resultcode},
            thread      => $t->{-thread},
            last_res    => $t->{-last_res},
            ticket      => $t->{-ticket},
            revision    => $t->{-revision},
            fork        => $t->{-fork},
            server_time => $t->{-server_time},
            view_counter=> $vc,
            chats       => \@chats,
            });

        $self->{_content_object} = $thread;
    }
    $self->{_content_object};
}

# TODO
sub is_content_success { # implement
    my $self = shift;
    my $tree = $self->parse;
    if( exists $tree->{packet} 
    and exists $tree->{packet}->{thread}
    ){
        return 1;
    }else{
        return 0;
    }
}

sub is_content_error { # implement
    not shift->is_content_success;
}

1;
