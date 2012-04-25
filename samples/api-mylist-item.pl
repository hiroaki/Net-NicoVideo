#!/usr/bin/env perl

use 5.12.0;
use warnings;
use Net::NicoVideo;

my $video_id = $ARGV[0] or die "usage: $0 video_id\n";

my $nnv = Net::NicoVideo->new;
my $mylistitem = $nnv->fetch_mylistitem($video_id);

say "video_id : ". $video_id;
say "token    : ". $mylistitem->token;
say "item_type: ". $mylistitem->item_type;
say "item_id  : ". $mylistitem->item_id;

1;
__END__
