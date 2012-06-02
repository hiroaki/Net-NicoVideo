#!/usr/bin/env perl

use 5.12.0;
use warnings;
use Net::NicoVideo;
use Net::NicoVideo::Content::NicoAPI;
use Getopt::Std;
use Data::Dumper;
local $Data::Dumper::Indent = 1;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

sub dump_as_yaml {
    require YAML;
    require YAML::Dumper;
    my $dumper = YAML::Dumper->new;
    $dumper->indent_width(4);
    $dumper->dump(@_);
}

my $opts = {};
getopts('d:i:o:ps:u:', $opts);
my $name = $ARGV[0] or die "usage: $0 [options...] name\n";

my $mylistgroup = Net::NicoVideo::Content::NicoAPI::MylistGroup->new({
    user_id         => $opts->{u},
    name            => $name,
    description     => $opts->{d},
    public          => ($opts->{p} ? '1' : '0'),
    default_sort    => $opts->{s},
    sort_order      => $opts->{o},
    icon_id         => $opts->{i},
    });

my $nnv = Net::NicoVideo->new;
my $added = $nnv->add_mylistgroup($mylistgroup);
say dump_as_yaml($added);

1;
__END__
