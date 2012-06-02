#!/usr/bin/env perl

use 5.12.0;
use warnings;
use Net::NicoVideo;
use Data::Dumper;
local $Data::Dumper::Indent = 1;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

my $group_id = $ARGV[0] or die "usage: $0 group_id video_id [description]\n";
my $video_id = $ARGV[1] or die "usage: $0 group_id video_id [description]\n";
my $desc     = $ARGV[2];

my $nnv = Net::NicoVideo->new;
my $mylistitem = $nnv->fetch_mylist_item($video_id);

$mylistitem->description($desc) if( defined $desc );

my $api = $nnv->add_mylist($group_id, $mylistitem, $mylistitem->token);

say 'status: '. $api->status;
unless( $api->is_status_ok ){
    say $api->error_description;
}else{
    say Data::Dumper::Dumper([$api]);
    say ref($api);
}

1;
__END__
