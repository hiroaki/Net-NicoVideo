#!/usr/bin/env perl

use 5.12.0;
use warnings;
use Getopt::Std;
use Net::NicoVideo;
use Data::Dumper;
local $Data::Dumper::Indent = 1;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

my $opts = {};
do {
    local $SIG{__WARN__} = sub { die @_ };
    getopts 'p:', $opts;
};

my $keyword = $ARGV[0] or die "usage: $0 [-p page] keyword\n";
my $page    = $opts->{p};

my $rss = Net::NicoVideo->new->fetch_tag_rss($keyword, { 'sort' => 'f', 'page' => $page });

say "title      : ". $rss->title;
say "description: ". $rss->description;
say "-----";

for my $item ( $rss->get_item ){
    printf '%s %s %s%s', $item->pubDate, $item->link, $item->title,"\n";
}

1;
__END__
