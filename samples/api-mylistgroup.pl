#!/usr/bin/env perl

use 5.12.0;
use warnings;
use Net::NicoVideo;
use Net::NicoVideo::Content::NicoAPI;

my $group_id = $ARGV[0];

my $nnv = Net::NicoVideo->new;
my $nico = $nnv->fetch_mylistgroup($group_id);

say 'status: '. $nico->status;
unless( $nico->is_status_ok ){
    say $nico->error_description;
}else{
    for my $mylist ( @{$nico->mylistgroup} ){
    
        say '-----';
        for my $mem ( Net::NicoVideo::Content::NicoAPI::MylistGroup::members ){
            say "$mem\t". ($mylist->$mem() // '(undef)');
        }
    }
}

1;
__END__
