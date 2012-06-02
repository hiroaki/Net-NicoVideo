#!/usr/bin/env perl

use strict;
use warnings;
use Net::NicoVideo;

binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

my $video_id = $ARGV[0] or die "usage: $0 video_id \n";

my $nnv = Net::NicoVideo->new;

my $info = $nnv->fetch_thumbinfo($video_id);
for ( $info->members ){
    print "$_: ".$info->$_()."\n";
}

1;
__END__
