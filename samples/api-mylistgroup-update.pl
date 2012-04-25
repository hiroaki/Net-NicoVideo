#!/usr/bin/env perl

use 5.12.0;
use warnings;
use Net::NicoVideo;
use Net::NicoVideo::Content::NicoAPI;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

my $group_id = $ARGV[0] or die "usage: $0 group_id\n";

my $nnv = Net::NicoVideo->new;
my $mylistgroup = $nnv->fetch_mylistgroup($group_id);

say 'status: '. $mylistgroup->status;
unless( $mylistgroup->is_status_ok ){
    say $mylistgroup->error_description;
}else{
    
    my $mylist = shift @{$mylistgroup->mylistgroup};
    for my $mem ( Net::NicoVideo::Content::NicoAPI::MylistGroup::members ){
        say "$mem\t". ($mylist->$mem() // '(undef)');
    }

    my $mg1 = $nnv->update_mylistgroup($mylist);
    say "update ". $mg1->status;

    $mylist->name($mylist->name. " copy");
    my $mg2 = $nnv->add_mylistgroup($mylist);
    say "add ". $mg2->id;

    $mylist->id($mg2->id);
    my $mg3 = $nnv->remove_mylistgroup($mylist);
    say "remove ". $mg3->status;

}
1;
__END__
