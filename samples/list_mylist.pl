#!/usr/bin/env perl

use 5.12.0;
use warnings;
use Net::NicoVideo;
use Data::Dumper;
local $Data::Dumper::Indent = 1;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

my $group_id = $ARGV[0] or die "usage: $0 group_id\n";

my $nnv = Net::NicoVideo->new;
my $api = $nnv->list_mylist($group_id); # Net::NicoVideo::Content::NicoAPI::MylistItem

say 'status: '. $api->status;
unless( $api->is_status_ok ){
    say $api->error_description;
}else{
    say Data::Dumper::Dumper([$api]);
    say ref($api);
    
    say "-----";
    for my $item ( @{$api->mylistitem} ){
        say "item_type          : ".$item->item_type;
        say "item_id            : ".$item->item_id;
        say "description        : ".$item->description;
        say "item_data->video_id: ".$item->item_data->video_id;
        say "item_data->title   : ".$item->item_data->title;
        say "-----";
    }
}

1;
__END__
