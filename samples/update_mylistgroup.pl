#!/usr/bin/env perl

use 5.12.0;
use warnings;
use Net::NicoVideo;
use Net::NicoVideo::Content::NicoAPI;
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

my $group_id = $ARGV[0] or die "usage: $0 group_id\n";

my $nnv = Net::NicoVideo->new;
my $api = $nnv->get_mylistgroup($group_id);
if( $api->status eq 'fail' ){
    die $api->error->description;
}

my $mylistgroup = shift @{$api->mylistgroup};
$mylistgroup->name($mylistgroup->name. " modified");
say "-- registering:";
say dump_as_yaml($mylistgroup);

my $updated = $nnv->update_mylistgroup($mylistgroup);

say "-- registered:";
say dump_as_yaml($updated);

1;
__END__
