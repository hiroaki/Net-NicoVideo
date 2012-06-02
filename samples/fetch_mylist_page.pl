#!/usr/bin/env perl

use 5.12.0;
use warnings;
use Net::NicoVideo;

my $page = Net::NicoVideo->new->fetch_mylist_page;
say "taken token: ". $page->token;

1;
__END__
