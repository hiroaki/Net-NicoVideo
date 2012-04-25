#!/usr/bin/env perl

use 5.12.0;
use warnings;
use Net::NicoVideo;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

use Getopt::Std;
my $opts = { c => 250 };
getopts('c:f',$opts);

my $video_id = $ARGV[0] or die "usage: $0 [-c num] [-f] video_id \n";

my $nnv = Net::NicoVideo->new;

my $thread  = $nnv->fetch_thread($video_id, { chats => $opts->{c}, 'fork' => $opts->{f} } );

say $thread->count;
for my $comm ( $thread->get_comments ){
    say $comm->value;
}

1;
__END__
